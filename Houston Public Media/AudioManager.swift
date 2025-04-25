//
//  HpmPlayer.swift
//  Houston Public Media
//
//  Created by Jared Counts on 11/8/24.
//
import AVFoundation
import Combine
import MediaPlayer
import SwiftUI

//TODO: manage transition from foreground to background for streaming audio
//TODO: manage recovery from stopped state

final class AudioManager: NSObject, ObservableObject, AVPlayerItemMetadataOutputPushDelegate {
	@Published var itemTitle: String = ""
	@Published var state: StateType = .stopped
	@Published var currentStation: Int = 0
	@Published var audioType: AudioType = .stream
	@Published var currentEpisode: PodcastEpisodePlayable? = nil
	enum StateType {
		case stopped, playing, paused
	}
	enum AudioType {
		case stream, episode
	}
	private var player: AVPlayer = AVPlayer()
	private var session = AVAudioSession.sharedInstance()
	
	private func activateSession() {
		do {
			try session.setCategory( .playback, mode: .default, options: [] )
		} catch _ {}
		
		do {
			try session.setActive(true, options: .notifyOthersOnDeactivation)
		} catch _ {}
		
		do {
			try session.overrideOutputAudioPort(.speaker)
		} catch _ {}
	}
	func startAudio(audioType: AudioType, station: Station? = nil, episode: PodcastEpisodePlayable? = nil) {
		var audioSource: String = ""
		var artist: String = ""
		var title: String = ""
		
		if audioType == .stream {
			guard let station = station else { return }
			audioSource = station.hlsSource
			artist = station.name
		} else {
			guard let episode = episode else { return }
			audioSource = episode.attachments.url
			artist = episode.podcastName
			title = episode.episodeTitle
			currentEpisode = episode
		}
		// activate our session before playing audio
		activateSession()
		let asset = AVURLAsset(url: URL(string: audioSource)!)
		let playerItem = AVPlayerItem(asset: asset)
		let metaOutput = AVPlayerItemMetadataOutput(identifiers: nil)
		metaOutput.setDelegate(self, queue: DispatchQueue.main)
		playerItem.add(metaOutput)
		player.replaceCurrentItem(with: playerItem)
		player.play()
		let commandCenter = MPRemoteCommandCenter.shared()
		commandCenter.playCommand.isEnabled = true
		commandCenter.nextTrackCommand.isEnabled = false
		commandCenter.previousTrackCommand.isEnabled = false
		if audioType == .stream {
			commandCenter.skipForwardCommand.isEnabled = false
			commandCenter.skipBackwardCommand.isEnabled = false
			commandCenter.stopCommand.isEnabled = true
			commandCenter.pauseCommand.isEnabled = false
		} else {
			commandCenter.pauseCommand.isEnabled = true
			commandCenter.stopCommand.isEnabled = false
			commandCenter.skipForwardCommand.isEnabled = true
			commandCenter.skipForwardCommand.preferredIntervals = [NSNumber(value: 15)]
			commandCenter.skipBackwardCommand.isEnabled = true
			commandCenter.skipBackwardCommand.preferredIntervals = [NSNumber(value: 15)]
		}
		
		commandCenter.playCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
			if self.state == .stopped && self.player.currentItem == nil {
				self.startAudio(audioType: .stream, station: station)
			} else {
				self.player.play()
				self.state = .playing
			}
			self.updatePlaybackRateMetadata()
			return .success
		}
		commandCenter.pauseCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
			self.player.pause()
			self.state = .paused
			self.updatePlaybackRateMetadata()
			return .success
		}
		commandCenter.stopCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
			self.stop()
			self.state = .stopped
			return .success
		}
		
		commandCenter.skipForwardCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
			if self.player.rate != 0.0 {
				let currentTime = self.player.currentTime()
				let offset = CMTimeMakeWithSeconds(15, preferredTimescale: 1)
				
				let newTime = CMTimeAdd(currentTime, offset)
				self.player.seek(to: newTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero, completionHandler: { (_) in
					self.updatePlaybackRateMetadata()
				})
				return .success
			}
			return .commandFailed
		}
		commandCenter.skipBackwardCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
			if self.player.rate != 0.0 {
				let currentTime = self.player.currentTime()
				let offset = CMTimeMakeWithSeconds(15, preferredTimescale: 1)
				
				let newTime = CMTimeSubtract(currentTime, offset)
				self.player.seek(to: newTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero, completionHandler: { (_) in
					self.updatePlaybackRateMetadata()
				})
				return .success
			}
			return .commandFailed
		}
		
		var defaultArtwork = UIImage(named: "ListenLive_News 88.7")
		if audioType == .stream {
			defaultArtwork = UIImage(named: "ListenLive_" + artist)
		} else {
			let filePath = GetPodcastArtwork(filename: (episode?.podcastName.convertedToSlug() ?? "") + ".webp")
			if filePath != nil {
				defaultArtwork = UIImage(contentsOfFile: filePath!)
			}
		}
		var nowPlayingInfo = [
			MPMediaItemPropertyTitle: title,
			MPMediaItemPropertyArtist: artist,
			MPMediaItemPropertyArtwork: MPMediaItemArtwork(boundsSize: defaultArtwork!.size) { @Sendable _ in
				defaultArtwork!
			}
		] as [String: Any]
		if audioType == .stream {
			nowPlayingInfo[MPNowPlayingInfoPropertyIsLiveStream] = true
		} else {
			let duration = GetDurationAsFloat(duration: episode?.attachments.duration_in_seconds ?? "0")
			nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
			nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(self.player.currentTime())
			nowPlayingInfo[MPNowPlayingInfoPropertyIsLiveStream] = false
		}
		MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
	}
	
	func updateMetadata(title: String) {
		var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo!
		nowPlayingInfo[MPMediaItemPropertyTitle] = title
		MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
	}
	
	func deactivateSession() {
		do {
			try session.setActive(false, options: .notifyOthersOnDeactivation)
			MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
		} catch let error as NSError {
			print("Failed to deactivate audio session: \(error.localizedDescription)")
		}
	}
	
	func play() {
		self.player.play()
	}
	
	func pause() {
		self.player.pause()
	}
	
	func stop() {
		self.player.replaceCurrentItem(with: nil)
	}
	
	func getPlaybackDuration() -> Double {
		return self.player.currentItem?.duration.seconds ?? 0
	}
	
	func metadataOutput(_ output: AVPlayerItemMetadataOutput, didOutputTimedMetadataGroups groups: [AVTimedMetadataGroup], from track: AVPlayerItemTrack?) {
		if groups.first?.items != nil {
			let item = groups.first?.items[1]
			let song = (item?.value(forKeyPath: "value") ?? "") as! String
			let songArr = song.components(separatedBy: "&")
			var outputArtist = ""
			var outputTitle = ""
			for songInfo in songArr {
				if songInfo != "" {
					let songInfoArr = songInfo.components(separatedBy: "=")
					if songInfoArr[0] == "artist" {
						outputArtist = songInfoArr[1].removingPercentEncoding ?? ""
					} else if songInfoArr[0] == "title" {
						outputTitle = songInfoArr[1].removingPercentEncoding ?? ""
					}
				}
			}
			if outputArtist == "Houston Public Media News" {
				self.itemTitle = outputTitle
			} else {
				self.itemTitle = outputArtist + " - " + outputTitle
			}
			updateMetadata(title: itemTitle)
		} else {
			self.itemTitle = "MetaData Error" // No Metadata or Could not read
		}
	}
	
	func updatePlaybackRateMetadata() {
		guard player.currentItem != nil else {
			return
		}
		
		var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [String: Any]()

		let duration = Float(CMTimeGetSeconds(self.player.currentItem!.duration))
		nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
		nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(self.player.currentTime())
		nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = self.player.rate
		nowPlayingInfo[MPNowPlayingInfoPropertyDefaultPlaybackRate] = self.player.rate
		
		MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
		
		if self.player.rate == 0.0 {
			state = .paused
			self.state = .paused
			#if os(macOS)
			nowPlayingInfoCenter.playbackState = .paused
			#endif
		} else {
			state = .playing
			self.state = .playing
			#if os(macOS)
			nowPlayingInfoCenter.playbackState = .playing
			#endif
		}
	}
	
	func GetDurationAsFloat(duration: String) -> Float {
		var totalDuration: Float = 0.0
		let split = duration.split(separator: ":")
		let count = split.count
		for index in 0..<count {
			let mult = pow(Double(60), Double(index))
			var floatVal = Float(split[count - index - 1]) ?? 0.0
			if index > 0 {
				floatVal *= Float(mult)
			}
			totalDuration += floatVal
		}
		return totalDuration
	}
}
