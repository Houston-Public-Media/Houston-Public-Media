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
				if UIDevice.current.userInterfaceIdiom == .pad {
					HStack(alignment: .top, spacing: 15) {
						AsyncImage(url: URL(string: data.podcasts.list[index].image.full.url)) { image in
							image.resizable().cornerRadius(8).aspectRatio(contentMode: .fit)
						} placeholder: {
							ProgressView()
						}
						VStack(spacing: 10) {
							Text(.init(description.htmlToMarkDown())).frame(maxWidth: .infinity, alignment: .leading)
							HStack(spacing: 15) {
								if !data.podcasts.list[index].external_links.itunes.isEmpty {
									Link(destination: URL(string: data.podcasts.list[index].external_links.itunes)!) {
										Image("Podcast-Apple")
											.resizable()
											.aspectRatio(1, contentMode: .fit)
											.cornerRadius(8)
											.frame(width: 40, height: 40)
											.accessibilityLabel("Link to Apple Podcasts for \(data.podcasts.list[index].name)")
									}
								}
								if !data.podcasts.list[index].external_links.spotify.isEmpty {
									Link(destination: URL(string: data.podcasts.list[index].external_links.spotify)!) {
										Image("Podcast-Spotify")
											.resizable()
											.aspectRatio(1, contentMode: .fit)
											.cornerRadius(8)
											.frame(width: 40, height: 40)
											.accessibilityLabel("Link to Spotify for \(data.podcasts.list[index].name)")
									}
								}
								if !data.podcasts.list[index].external_links.npr.isEmpty {
									Link(destination: URL(string: data.podcasts.list[index].external_links.npr)!) {
										Image("Podcast-NPR")
											.resizable()
											.aspectRatio(1, contentMode: .fit)
											.cornerRadius(8)
											.frame(width: 40, height: 40)
											.accessibilityLabel("Link to NPR App for \(data.podcasts.list[index].name)")
									}
								}
								if !data.podcasts.list[index].external_links.pcast.isEmpty {
									Link(destination: URL(string: data.podcasts.list[index].external_links.pcast)!) {
										Image("Podcast-PocketCasts")
											.resizable()
											.aspectRatio(1, contentMode: .fit)
											.cornerRadius(8)
											.frame(width: 40, height: 40)
											.accessibilityLabel("Link to PocketCasts for \(data.podcasts.list[index].name)")
									}
								}
								Link(destination: URL(string: data.podcasts.list[index].feed)!) {
									Image("Podcast-RSS")
										.resizable()
										.aspectRatio(1, contentMode: .fit)
										.cornerRadius(8)
										.frame(width: 40, height: 40)
										.accessibilityLabel("RSS feed for \(data.podcasts.list[index].name)")
								}
							}
						}
					}
					.listRowBackground(Color.clear)
				} else {
					VStack {
						AsyncImage(url: URL(string: data.podcasts.list[index].image.full.url)) { image in
							image.resizable().cornerRadius(8).aspectRatio(contentMode: .fit)
						} placeholder: {
							ProgressView()
						}
						Text(.init(description.htmlToMarkDown())).frame(maxWidth: .infinity, alignment: .leading)
						HStack(spacing: 15) {
							if !data.podcasts.list[index].external_links.itunes.isEmpty {
								Link(destination: URL(string: data.podcasts.list[index].external_links.itunes)!) {
									Image("Podcast-Apple")
										.resizable()
										.aspectRatio(1, contentMode: .fit)
										.cornerRadius(8)
										.frame(width: 40, height: 40)
										.accessibilityLabel("Link to Apple Podcasts for \(data.podcasts.list[index].name)")
								}
							}
							if !data.podcasts.list[index].external_links.spotify.isEmpty {
								Link(destination: URL(string: data.podcasts.list[index].external_links.spotify)!) {
									Image("Podcast-Spotify")
										.resizable()
										.aspectRatio(1, contentMode: .fit)
										.cornerRadius(8)
										.frame(width: 40, height: 40)
										.accessibilityLabel("Link to Spotify for \(data.podcasts.list[index].name)")
								}
							}
							if !data.podcasts.list[index].external_links.npr.isEmpty {
								Link(destination: URL(string: data.podcasts.list[index].external_links.npr)!) {
									Image("Podcast-NPR")
										.resizable()
										.aspectRatio(1, contentMode: .fit)
										.cornerRadius(8)
										.frame(width: 40, height: 40)
										.accessibilityLabel("Link to NPR App for \(data.podcasts.list[index].name)")
								}
							}
							if !data.podcasts.list[index].external_links.pcast.isEmpty {
								Link(destination: URL(string: data.podcasts.list[index].external_links.pcast)!) {
									Image("Podcast-PocketCasts")
										.resizable()
										.aspectRatio(1, contentMode: .fit)
										.cornerRadius(8)
										.frame(width: 40, height: 40)
										.accessibilityLabel("Link to PocketCasts for \(data.podcasts.list[index].name)")
								}
							}
							Link(destination: URL(string: data.podcasts.list[index].feed)!) {
								Image("Podcast-RSS")
									.resizable()
									.aspectRatio(1, contentMode: .fit)
									.cornerRadius(8)
									.frame(width: 40, height: 40)
									.accessibilityLabel("RSS feed for \(data.podcasts.list[index].name)")
							}
						}
					}
					.listRowBackground(Color.clear)
				}
			}
			.headerProminence(.increased)
			.buttonStyle(BorderlessButtonStyle())
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
								attachments: episode.attachments,
								duration: episode.attachments.duration_in_seconds
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
		.refreshable {
			await data.podcastPull(index: index)
		}
	}
}

#Preview {
	PodcastDetailView(index: 0).environmentObject(StationData()).environmentObject(AudioManager())
}
