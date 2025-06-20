//
//  View-AudioPlayer.swift
//  HPM
//
//  Created by Jared Counts on 11/20/24.
//

import SwiftUI

struct AudioPlayerView: View {
	@EnvironmentObject var data: StationData
	@EnvironmentObject var playback: AudioManager
	@State private var isShowingSheet = false
    var body: some View {
		
		HStack {
			if playback.audioType == .stream {
				Image("ListenLive_" + data.streams.audio[playback.currentStation].name)
					.resizable()
					.frame(width: 30, height: 30)
			} else {
				AsyncImage(url: URL(string: playback.currentEpisode?.image.full.url ?? "")) { image in
					image.resizable().aspectRatio(contentMode: .fit).frame(width: 30, height: 30)
				} placeholder: {
					ProgressView()
				}
			}
			if playback.state != .playing {
				Button(action: {
					playback.play()
					playback.state = .playing
				}, label: {
					Image(systemName: "play.fill").accessibilityLabel("Play")
				})
				.frame(width: 30, height: 30)
			} else {
				Button(action: {
					playback.pause()
					playback.state = .paused
				}, label: {
					Image(systemName: "pause.fill").accessibilityLabel("Pause")
				})
				.frame(width: 30, height: 30)
			}
			VStack {
				if playback.state != .stopped {
					if playback.audioType == .stream {
						Text(data.streams.audio[playback.currentStation].name)
							.font(.system(size: 12, weight: .bold))
							.frame(maxWidth: .infinity, alignment: .leading)
						Text(nowPlayingCleanup(nowPlaying: data.nowPlaying.radio[playback.currentStation]))
							.font(.system(size: 11, weight: .regular))
							.frame(maxWidth: .infinity, alignment: .leading)
					} else {
						Text(playback.currentEpisode?.podcastName ?? "")
							.font(.system(size: 12, weight: .bold))
							.frame(maxWidth: .infinity, alignment: .leading)
						Text(playback.currentEpisode?.episodeTitle ?? "")
							.font(.system(size: 11, weight: .regular))
							.frame(maxWidth: .infinity, alignment: .leading)
					}
				}
			}
			Spacer()
			Button(action: {
				isShowingSheet.toggle()
			}) {
				Image(systemName:"chevron.up").accessibilityLabel("Open Audio Player Control")
			}
		}
		.sheet(isPresented: $isShowingSheet, onDismiss: didDismiss) {
			AudioPlayerPopupView()
		}
    }
	func didDismiss() {
		// Handle the dismissing action.
	}
}

#Preview {
    AudioPlayerView()
		.environmentObject(StationData())
		.environmentObject(AudioManager())
}
