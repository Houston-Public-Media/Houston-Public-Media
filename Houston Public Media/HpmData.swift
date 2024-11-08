//
//  HpmStreams.swift
//  Houston Public Media
//
//  Created by Jared Counts on 10/16/24.
//


struct HpmStreams: Decodable {
	let audio: [HpmStation]
	let video: [HpmStation]
	func update() async throws -> HpmStreams {
		let streams: HpmStreams = try await URLSession.shared.decode(from: URL(string: "https://cdn.houstonpublicmedia.org/assets/streams.json")!)
		return streams
	}
}
struct HpmStation: Decodable, Identifiable {
	let id: UUID
	let name: String
	var artwork: String? = nil
	let sources: HpmAvSources
}
struct HpmAvSources: Decodable {
	var aac: HpmAvSource? = nil
	var mp3: HpmAvSource? = nil
	let hls: HpmAvSource
	var dash: HpmAvSource? = nil
}
struct HpmAvSource: Decodable {
	let src: String
	let type: String
	let drm: Bool
}
struct HpmPodcastApiCall: Decodable {
	let code: String
	let message: String
	let data: HpmPodcastList
}
struct HpmPodcastList: Decodable {
	let list: [HpmPodcast]
	func update() async throws -> HpmPodcastList {
		let podcasts: HpmPodcastApiCall = try await URLSession.shared.decode(from: URL(string: "https://www.houstonpublicmedia.org/wp-json/hpm-podcast/v1/list")!)
		return podcasts.data
	}
}
struct HpmPodcast: Decodable, Identifiable {
	let id: UUID
	let image: HpmImageCrops
	let latest_episode: HpmPodcastEpisode
	let feed: String
	let archive: String
	let slug: String
	let name: String
	let description: String
	let feed_json: String
}
struct HpmPodcastEpisode: Decodable {
	let audio: String
	let title: String
	let link: String
}
struct HpmImageCrops: Decodable {
	let full: HpmImageCrop
	let medium: HpmImageCrop
	let thumbnail: HpmImageCrop
}
struct HpmImageCrop: Decodable {
	let url: String
	let width: Int
	let height: Int
}
struct HpmPriorityArticle: Identifiable, Decodable {
	let id: Int
	let title: String
	let excerpt: String
	let picture: String
	let permalink: String
}
struct HpmPriorityApiCall: Decodable {
	let code: String
	let message: String
	let data: HpmPriorityArticleData
}
struct HpmPriorityArticleData: Decodable {
	let articles: [HpmPriorityArticle]
	let status: Int
}
var streams = HpmStreams(
	audio: [
		HpmStation(
			id: UUID(),
			name: "News 88.7",
			artwork: "https://cdn.houstonpublicmedia.org/assets/images/ListenLive_News.png.webp",
			sources: HpmAvSources(
				aac: HpmAvSource(
					src: "https://stream.houstonpublicmedia.org/news-aac",
					type: "audio/aac",
					drm: false
				),
				mp3: HpmAvSource(
					src: "https://stream.houstonpublicmedia.org/news-mp3",
					type: "audio/mpeg",
					drm: false
				),
				hls: HpmAvSource(
					src: "https://hls.houstonpublicmedia.org/hpmnews/playlist.m3u8",
					type: "application/vnd.apple.mpegurl",
					drm: false
				)
			)
		),
		HpmStation(
			id: UUID(),
			name: "Classical",
			artwork: "https://cdn.houstonpublicmedia.org/assets/images/ListenLive_Classical.png.webp",
			sources: HpmAvSources(
				aac: HpmAvSource(
					src: "https://stream.houstonpublicmedia.org/classical-aac",
					type: "audio/aac",
					drm: false
				),
				mp3: HpmAvSource(
					src: "https://stream.houstonpublicmedia.org/classical-mp3",
					type: "audio/mpeg",
					drm: false
				),
				hls: HpmAvSource(
					src: "https://hls.houstonpublicmedia.org/classical/playlist.m3u8",
					type: "application/vnd.apple.mpegurl",
					drm: false
				)
			)
		),
		HpmStation(
			id: UUID(),
			name: "Mixtape",
			artwork: "https://cdn.houstonpublicmedia.org/assets/images/ListenLive_Mixtape.png.webp",
			sources: HpmAvSources(
				aac: HpmAvSource(
					src: "https://stream.houstonpublicmedia.org/mixtape-aac",
					type: "audio/aac",
					drm: false
				),
				mp3: HpmAvSource(
					src: "https://stream.houstonpublicmedia.org/mixtape-mp3",
					type: "audio/mpeg",
					drm: false
				),
				hls: HpmAvSource(
					src: "https://hls.houstonpublicmedia.org/mixtape/playlist.m3u8",
					type: "application/vnd.apple.mpegurl",
					drm: false
				)
			)
		)
	],
	video: [
		HpmStation(
			id: UUID(),
			name: "TV 8",
			artwork: "",
			sources: HpmAvSources(
				hls: HpmAvSource(
					src: "https://urs-anonymous-detect.pbs.org/redirect/630ecd724ee34204b2a55fa1a4e74f7c/",
					type: "application/vnd.apple.mpegurl",
					drm: true
				),
				dash: HpmAvSource(
					src: "https://urs-anonymous-detect.pbs.org/redirect/29e52d125db9409ca8090d7c590d7950/",
					type: "application/dash+xml",
					drm: true
				)
			)
		),
		HpmStation(
			id: UUID(),
			name: "PBS Kids",
			artwork: "",
			sources: HpmAvSources(
				hls: HpmAvSource(
					src: "https://urs-anonymous-detect.pbs.org/redirect/10db90c781b240f2a3ea78656bfe914a/",
					type: "application/vnd.apple.mpegurl",
					drm: true
				),
				dash: HpmAvSource(
					src: "https://urs-anonymous-detect.pbs.org/redirect/10db90c781b240f2a3ea78656bfe914a/",
					type: "application/dash+xml",
					drm: true
				)
			)
		),
		HpmStation(
			id: UUID(),
			name: "PBS World",
			artwork: "",
			sources: HpmAvSources(
				hls: HpmAvSource(
					src: "https://urs.pbs.org/redirect/186af0c44ec24ace9b8b908abf93e0f4/",
					type: "application/vnd.apple.mpegurl",
					drm: false
				)
			)
		),
		HpmStation(
			id: UUID(),
			name: "NHK World",
			artwork: "",
			sources: HpmAvSources(
				hls: HpmAvSource(
					src: "https://urs.pbs.org/redirect/3dee3319e51d49828a2a2a5f05e6c449/",
					type: "application/vnd.apple.mpegurl",
					drm: false
				)
			)
		)
	]
)

struct VideoPlayerView: UIViewControllerRepresentable {
	var videoURL: URL
	func makeUIViewController(context: Context) -> AVPlayerViewController {
		let player = AVPlayer(url: videoURL)
		let playerController = AVPlayerViewController()
		playerController.player = player
		player.play()
		return playerController
	}
	func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
}
