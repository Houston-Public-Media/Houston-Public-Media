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

final class AudioManager: NSObject, ObservableObject, AVPlayerItemMetadataOutputPushDelegate {
	@Published var itemTitle: String = ""
	@Published var state: StateType = .stopped
	@Published var currentStation: Int = 0
	enum StateType {
		case stopped, playing, paused
	}
	private var player: AVPlayer?
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
	func startAudio(station: Station) {
			
		// activate our session before playing audio
		activateSession()
		let asset = AVURLAsset(url: URL(string: station.hlsSource)!)
		let playerItem = AVPlayerItem(asset: asset)
		let metaOutput = AVPlayerItemMetadataOutput(identifiers: nil)
		metaOutput.setDelegate(self, queue: DispatchQueue.main)
		playerItem.add(metaOutput)
		if let player = player {
			player.replaceCurrentItem(with: playerItem)
		} else {
			player = AVPlayer(playerItem: playerItem)
		}
		
		if let player = player {
			player.play()
			let commandCenter = MPRemoteCommandCenter.shared()
			commandCenter.playCommand.isEnabled = true
			commandCenter.nextTrackCommand.isEnabled = false
			commandCenter.previousTrackCommand.isEnabled = false
			commandCenter.skipForwardCommand.isEnabled = false
			commandCenter.skipBackwardCommand.isEnabled = false
			commandCenter.pauseCommand.isEnabled = true
			
			commandCenter.playCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
				if self.player?.rate == 0.0 {
					self.player?.play()
					return .success
				}
				return .commandFailed
			}
			commandCenter.pauseCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
				if self.player?.rate != 0.0 {
					self.player?.pause()
					return .success
				}
				return .commandFailed
			}
			let defaultArtwork = UIImage(named: "ListenLive_" + station.name)!
			var nowPlayingInfo = [
				MPMediaItemPropertyTitle: self.itemTitle,
				MPMediaItemPropertyArtist: station.name,
				MPMediaItemPropertyArtwork: MPMediaItemArtwork(boundsSize: defaultArtwork.size) { @Sendable _ in
					defaultArtwork
				}
			] as [String: Any]
			nowPlayingInfo[MPNowPlayingInfoPropertyIsLiveStream] = true
			MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
		}
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
		if let player = player {
			player.play()
		}
	}

	func pause() {
		if let player = player {
			player.pause()
		}
	}

	func getPlaybackDuration() -> Double {
		guard let player = player else {
			return 0
		}
	 
		return player.currentItem?.duration.seconds ?? 0
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
}

