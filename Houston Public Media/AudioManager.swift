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

let timeScale = CMTimeScale(1000)
let time = CMTime(seconds: 0.5, preferredTimescale: timeScale)

final class AudioManager: NSObject, ObservableObject, AVPlayerItemMetadataOutputPushDelegate {
	@Published var state: StateType = .stopped
	@Published var currentStation: Int = 0
	@Published var audioType: AudioType = .stream
	@Published var currentEpisode: PodcastEpisodePlayable? = nil
	/// Display time that will be bound to the scrub slider.
	@Published var displayTime: TimeInterval = 0

	/// The observed time, which may not be needed by the UI.
	@Published var observedTime: TimeInterval = 0

	@Published var itemDuration: TimeInterval = 0
	fileprivate var itemDurationKVOPublisher: AnyCancellable!

	/// Publish timeControlStatus
	@Published var timeControlStatus: AVPlayer.TimeControlStatus = .paused
	fileprivate var timeControlStatusKVOPublisher: AnyCancellable!
	fileprivate var periodicTimeObserver: Any?
	
	enum StateType {
		case stopped, playing, paused
	}
	enum AudioType {
		case stream, episode
	}
	enum PlayerScrubState {
		case reset
		case scrubStarted
		case scrubEnded(TimeInterval)
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
			self.addPeriodicTimeObserver()
			self.addTimeControlStatusObserver()
			self.addItemDurationPublisher()
		}
		// activate our session before playing audio
		activateSession()
		let asset = AVURLAsset(url: URL(string: audioSource)!)
		let playerItem = AVPlayerItem(asset: asset)
		if audioType == .stream {
			playerItem.preferredPeakBitRate = 64000
		}

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
			self.skipForward()
			return .success
		}
		commandCenter.skipBackwardCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
			self.skipBackward()
			return .success
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
	
	func deactivateSession() {
		do {
			try session.setActive(false, options: .notifyOthersOnDeactivation)
			MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
			removePeriodicTimeObserver()
			timeControlStatusKVOPublisher.cancel()
			itemDurationKVOPublisher.cancel()
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
	
	func skipForward() {
		let currentTime = self.player.currentTime()
		let offset = CMTimeMakeWithSeconds(15, preferredTimescale: 1)
		
		let newTime = CMTimeAdd(currentTime, offset)
		self.player.seek(to: newTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero, completionHandler: { (_) in
			self.updatePlaybackRateMetadata()
		})
	}
	func skipBackward() {
		let currentTime = self.player.currentTime()
		let offset = CMTimeMakeWithSeconds(15, preferredTimescale: 1)
		
		let newTime = CMTimeSubtract(currentTime, offset)
		self.player.seek(to: newTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero, completionHandler: { (_) in
			self.updatePlaybackRateMetadata()
		})
	}
	
	func getPlaybackDuration() -> Double {
		return self.player.currentItem?.duration.seconds ?? 0
	}
	
	func metadataOutput(_ output: AVPlayerItemMetadataOutput, didOutputTimedMetadataGroups groups: [AVTimedMetadataGroup], from track: AVPlayerItemTrack?) {
		var outputArtist = ""
		var outputTitle = ""
		if groups.first?.items != nil {
			for item in groups.first?.items ?? [] {
				if item.commonKey != nil {
					if item.commonKey == AVMetadataKey.commonKeyArtist {
						outputArtist = (item.value(forKeyPath: "value") ?? "") as! String
					} else if item.commonKey == AVMetadataKey.commonKeyTitle {
						outputTitle = (item.value(forKeyPath: "value") ?? "") as! String
					}
				}
			}
			updateMetadata(title: outputTitle, artist: outputArtist)
		}
	}
	
	func updateMetadata(title: String, artist: String) {
		var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo!
		nowPlayingInfo[MPMediaItemPropertyTitle] = title
		nowPlayingInfo[MPMediaItemPropertyArtist] = artist
		MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
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
	
	var scrubState: PlayerScrubState = .reset {
		didSet {
			switch scrubState {
			case .reset:
				return
			case .scrubStarted:
				return
			case .scrubEnded(let seekTime):
				self.player.seek(to: CMTime(seconds: seekTime, preferredTimescale: 1000))
			}
		}
	}
	
	fileprivate func addPeriodicTimeObserver() {
		self.periodicTimeObserver = self.player.addPeriodicTimeObserver(forInterval: time, queue: .main) { [weak self] (time) in
			guard let self = self else { return }

			// Always update observed time.
			self.observedTime = time.seconds

			switch self.scrubState {
			case .reset:
				self.displayTime = time.seconds
			case .scrubStarted:
				// When scrubbing, the displayTime is bound to the Slider view, so
				// do not update it here.
				break
			case .scrubEnded(let seekTime):
				self.scrubState = .reset
				self.displayTime = seekTime
			}
		}
	}

	fileprivate func removePeriodicTimeObserver() {
		guard let periodicTimeObserver = self.periodicTimeObserver else {
			return
		}
		self.player.removeTimeObserver(periodicTimeObserver)
		self.periodicTimeObserver = nil
	}

	fileprivate func addTimeControlStatusObserver() {
		timeControlStatusKVOPublisher = self.player
			.publisher(for: \.timeControlStatus)
			.receive(on: DispatchQueue.main)
			.sink(receiveValue: { [weak self] (newStatus) in
				guard let self = self else { return }
				self.timeControlStatus = newStatus
				}
		)
	}

	fileprivate func addItemDurationPublisher() {
		itemDurationKVOPublisher = self.player
			.publisher(for: \.currentItem?.duration)
			.receive(on: DispatchQueue.main)
			.sink(receiveValue: { [weak self] (newStatus) in
				guard let newStatus = newStatus,
					let self = self else { return }
				self.itemDuration = newStatus.seconds
				}
		)
	}
}
