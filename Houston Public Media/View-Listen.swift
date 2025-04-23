//
//  HpmListenView.swift
//  HPM
//
//  Created by Jared Counts on 11/12/24.
//

import SwiftUI
import AVKit

struct ListenView: View {
	@EnvironmentObject var data: StationData
	@EnvironmentObject var playback: AudioManager
	var body: some View {
		VStack(spacing: 0) {
			TabHeaderView(section: "Listen")
			NavigationStack {
				List {
					Section(header: Text("Radio Streams")) {
						ForEach(data.streams.audio, id: \.id) { station in
							HStack {
								Image("ListenLive_" + station.name)
									.resizable()
									.frame(width: 50, height: 50)
								VStack {
									Text(station.name)
										.font(.headline)
										.fontWeight(.bold)
										.frame(maxWidth: .infinity, alignment: .leading)
									Text(nowPlayingCleanup(nowPlaying: data.nowPlaying.radio[station.id]))
										.font(.system(size: 11, weight: .regular))
										.frame(maxWidth: .infinity, alignment: .leading)
								}
								Spacer()
								Button(action: {
									if playback.state == .playing && playback.currentStation == station.id {
										playback.pause()
										playback.state = .paused
									} else {
										playback.startAudio(audioType: .stream, station: station)
										playback.state = .playing
										playback.currentStation = station.id
										playback.audioType = .stream
									}
								}, label: {
									if playback.state == .playing && playback.currentStation == station.id {
										Image(systemName: "pause.fill").accessibilityLabel("Pause \(station.name)")
									} else {
										Image(systemName: "play.fill").accessibilityLabel("Play \(station.name)")
									}
								})
							}
						}
					}
					.headerProminence(.increased)
					Section(header: Text("Podcasts")) {
						ForEach(Array(data.podcasts.list.enumerated()), id: \.offset) { index, podcast in
							NavigationLink(destination: PodcastDetailView(data: _data, index: index)) {
								HStack {
									AsyncImage(url: URL(string: podcast.image.full.url)) { image in
										image.resizable().cornerRadius(10)
									} placeholder: {
										ProgressView()
									}
									.frame(width: 50, height: 50)
									Text(podcast.name)
								}
							}
						}
					}
					.headerProminence(.increased)
				}
			}
				.border(width: 1, edges: [.top], color: .gray)
		}
	}
}

#Preview {
	ListenView().environmentObject(StationData()).environmentObject(AudioManager())
}
