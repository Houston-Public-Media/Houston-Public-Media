//
//  View-PodcastDetail.swift
//  HPM
//
//  Created by Jared Counts on 3/21/25.
//
import SwiftUI
import HTMLEntities

struct PodcastDetailView: View {
	@EnvironmentObject var data: StationData
	@EnvironmentObject var playback: AudioManager
	var index: Int
	var body: some View {
		let description = data.podcasts.list[index].description
		List {
			Section(header: Text(data.podcasts.list[index].name)) {
				VStack {
					AsyncImage(url: URL(string: data.podcasts.list[index].image.full.url)) { image in
						image.resizable().cornerRadius(10).aspectRatio(contentMode: .fit)
					} placeholder: {
						ProgressView()
					}
					Text(.init(description.htmlToMarkDown())).frame(maxWidth: .infinity, alignment: .leading)
				}
				.listRowBackground(Color.clear)
			}
			.headerProminence(.increased)
			Section(header: Text("Episodes")) {
				ForEach(data.podcasts.list[index].episodelist ?? [], id: \.id) { episode in
					HStack {
						if !episode.thumbnail.isEmpty {
							AsyncImage(url: URL(string: episode.thumbnail)) { image in
								image.resizable().aspectRatio(contentMode: .fit).frame(width: 60, height: 60)
							} placeholder: {
								ProgressView()
							}
						}
						VStack {
							Text(episode.title.htmlUnescape()).font(.system(size: 16, weight: .regular)).frame(maxWidth: .infinity, alignment: .leading).padding(.bottom, 3)
							HStack {
								Text(wpDateFormatter(date: episode.date_gmt)).font(.system(size: 12, weight: .regular)).frame(maxWidth: .infinity, alignment: .leading)
								Text(episode.attachments.duration_in_seconds).font(.system(size: 12, weight: .regular)).frame(maxWidth: .infinity, alignment: .trailing)
							}
						}
						Button(action: {
							let podEp = PodcastEpisodePlayable(
								id: episode.id,
								image: data.podcasts.list[index].image,
								podcastName: data.podcasts.list[index].name,
								episodeTitle: episode.title.htmlUnescape(),
								excerpt: episode.excerpt,
								date_gmt: episode.date_gmt,
								thumbnail: episode.thumbnail,
								attachments: episode.attachments
							)
							if playback.state == .playing {
								playback.pause()
								if playback.currentStation != episode.id {
									playback.startAudio(audioType: .episode, episode: podEp)
									playback.state = .playing
									playback.currentStation = episode.id
									playback.audioType = .episode
									playback.currentEpisode = podEp
								}
							} else {
								if playback.currentStation == podEp.id {
									playback.play()
								} else {
									playback.startAudio(audioType: .episode, episode: podEp)
									playback.state = .playing
									playback.currentStation = episode.id
									playback.audioType = .episode
									playback.currentEpisode = podEp
								}
							}
						}, label: {
							if playback.state == .playing && playback.currentStation == episode.id {
								Image(systemName: "pause.fill").accessibilityLabel("Pause episode")
							} else {
								Image(systemName: "play.fill").accessibilityLabel("Play episode")
							}
						})
					}
				}
			}
			.headerProminence(.increased)
		}
		.task {
			if data.podcasts.list[index].episodelist == nil {
				Task {
					await data.podcastPull(index: index)
				}
			}
		}
	}
}

#Preview {
	PodcastDetailView(index: 0).environmentObject(StationData()).environmentObject(AudioManager())
}
