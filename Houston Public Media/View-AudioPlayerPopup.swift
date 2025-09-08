//
//  View-AudioPlayerPopup.swift
//  HPM
//
//  Created by Jared Counts on 5/27/25.
//

import SwiftUI

struct AudioPlayerPopupView: View {
	@EnvironmentObject var data: StationData
	@EnvironmentObject var playback: AudioManager
	@State var value :Double = 2.0
	var body: some View {
		VStack {
			Capsule()
				.fill(Color.secondary)
				.opacity(0.5)
				.frame(width: 35, height: 5)
				.padding(.horizontal, 6)
				.padding(.top, 6)
				.padding(.bottom, 40)
			if playback.audioType == .stream {
				Image("ListenLive_" + data.streams.audio[playback.currentStation].name)
					.resizable()
					.frame(width: 300, height: 300)
					.aspectRatio(contentMode: .fit)
					.cornerRadius(8)
					.padding(10)
				Text(data.streams.audio[playback.currentStation].name)
					.font(.system(size: 14, weight: .semibold))
					.frame(maxWidth: .infinity, alignment: .center)
					.multilineTextAlignment(.center)
					.padding(.horizontal, 10)
				Text(nowPlayingCleanup(nowPlaying: data.nowPlaying.radio[playback.currentStation]))
					.font(.system(size: 16, weight: .regular))
					.frame(maxWidth: .infinity, alignment: .center)
					.padding(.bottom, 10)
					.padding(.horizontal, 10)
					.multilineTextAlignment(.center)
			} else {
				AsyncImage(url: URL(string: playback.currentEpisode?.image.full.url ?? "")) { image in
					image
						.resizable()
						.frame(width: 300, height: 300)
						.aspectRatio(contentMode: .fit)
						.cornerRadius(8)
						.padding(10)
				} placeholder: {
					ProgressView()
				}
				Text(playback.currentEpisode?.podcastName ?? "")
					.font(.system(size: 14, weight: .semibold))
					.frame(maxWidth: .infinity, alignment: .center)
					.multilineTextAlignment(.center)
					.padding(.horizontal, 10)
				Text(playback.currentEpisode?.episodeTitle ?? "")
					.font(.system(size: 16, weight: .regular))
					.frame(maxWidth: .infinity, alignment: .center)
					.padding(.bottom, 10)
					.padding(.horizontal, 10)
					.multilineTextAlignment(.center)
			}
			
			/// This is a bit of a hack, but it takes a moment for the AVPlayerItem to load
			/// the duration, so we need to avoid adding the slider until the range
			/// (0...self.player.duration) is not empty.
			if playback.audioType != .stream {
				if playback.itemDuration > 0 {
					VStack {
						Slider(value: $playback.displayTime, in: (0...playback.itemDuration), onEditingChanged: {
							(scrubStarted) in
							if scrubStarted {
								playback.scrubState = .scrubStarted
							} else {
								playback.scrubState = .scrubEnded(playback.displayTime)
							}
						})
						HStack {
							Text(self.durationFormatter.string(from: playback.displayTime) ?? "")
								.font(.system(size: 12, weight: .regular))
							Spacer()
							Text(self.durationFormatter.string(from: playback.itemDuration) ?? "")
								.font(.system(size: 12, weight: .regular))
						}
					}
						.padding(10)
				}
			} else {
				ZStack {
					Text("Live")
						.font(.system(size: 12, weight: .regular))
						.padding(5)
						.frame(width: 150, height: 24)
					RoundedRectangle(cornerRadius: 8)
						.frame(width: 350, height: 16)
						.foregroundStyle(Color.secondary)
				}
				.padding(10)
			}
			HStack(spacing: 50) {
				if playback.audioType == .episode {
					Button(action: {
						print("Skip Backwards")
						playback.skipBackward()
					}, label: {
						Image(systemName: "15.arrow.trianglehead.counterclockwise")
							.resizable()
							.frame(width: 40, height: 40)
							.accessibilityLabel("Skip 15 seconds backward")
					})
				}
				if playback.state != .playing {
					Button(action: {
						playback.play()
						playback.state = .playing
					}, label: {
						Image(systemName: "play.fill")
							.resizable()
							.frame(width: 50, height: 50)
							.accessibilityLabel("Play")
					})
				} else {
					Button(action: {
						playback.pause()
						playback.state = .paused
					}, label: {
						Image(systemName: "pause.fill")
							.resizable()
							.frame(width: 50, height: 50)
							.accessibilityLabel("Pause")
					})
				}
				if playback.audioType == .episode {
					Button(action: {
						print("Skip Forwards")
						playback.skipForward()
					}, label: {
						Image(systemName: "15.arrow.trianglehead.clockwise")
							.resizable()
							.frame(width: 40, height: 40)
							.accessibilityLabel("Skip 15 seconds forward")
					})
				}
			}
			Spacer()
		}
	}
	var durationFormatter: DateComponentsFormatter {
		let durationFormatter = DateComponentsFormatter()
		durationFormatter.allowedUnits = [.minute, .second]
		durationFormatter.unitsStyle = .positional
		durationFormatter.zeroFormattingBehavior = .pad
		return durationFormatter
	}
}

#Preview {
	AudioPlayerPopupView()
		.environmentObject(StationData())
		.environmentObject(AudioManager())
}
