//
//  HpmStreams.swift
//  Houston Public Media
//
//  Created by Jared Counts on 10/16/24.
//
import Foundation
import TinyStorage

struct Streams: Decodable {
	let audio: [Station]
}
struct Station: Decodable, Identifiable, Hashable {
	var id: Int
	var name: String
	var type: String
	var artwork: String
	var aacSource: String
	var mp3Source: String
	var hlsSource: String
}
struct PodcastApiCall: Decodable {
	let code: String
	let message: String
	let data: PodcastList
}
struct PodcastDetailApiCall: Decodable {
	let code: String
	let message: String
	let data: PodcastFeedDetail
}
struct PodcastFeedDetail: Decodable {
	let feed: PodcastFeedItems
}
struct PodcastFeedItems: Decodable {
	let items: [PodcastEpisode]
}
struct PodcastList: Decodable {
	var list: [Podcast]
}
struct Podcast: Identifiable, Decodable {
	let id: Int
	let image: ImageCrops
	let feed: String
	let archive: String
	let slug: String
	let name: String
	let description: String
	let feed_json: String
	var episodelist: [PodcastEpisode]?
	let external_links: PodcastExternalLinks
}
struct PodcastExternalLinks: Decodable {
	let itunes: String
	let npr: String
	let youtube: String
	let spotify: String
	let pcast: String
	let overcast: String
	let amazon: String
	let tunein: String
	let pandora: String
	let iheart: String
}
struct PodcastEpisode: Identifiable, Decodable {
	let id: Int
	let title: String
	let permalink: String
	let content_html: String
	let excerpt: String
	let date: Date
	let date_gmt: Date
	let author: String
	let thumbnail: String
	let season: String
	let episode: String
	let episodeType: String
	let attachments: PodcastEnclosure
}
struct PodcastEnclosure: Decodable {
	let url: String
	let duration_in_seconds: String
}
struct PodcastEpisodePlayable: Decodable {
	let id: Int
	let image: ImageCrops
	let podcastName: String
	let episodeTitle: String
	let excerpt: String
	let date_gmt: Date
	let thumbnail: String
	let attachments: PodcastEnclosure
	let duration: String
}
struct ImageCrops: Decodable {
	let full: ImageCrop
	let medium: ImageCrop
	let thumbnail: ImageCrop
}
struct ImageCrop: Decodable {
	let url: String
	let width: Int
	let height: Int
}
struct PriorityApiCall: Decodable {
	let code: String
	let message: String
	let data: PriorityArticleData
}
struct PriorityArticleData: Decodable {
	let articles: [PriorityArticle]
	let breaking: BreakingNews
	let talkshow: String
	let weather: HpmWeather
}
struct BreakingNews: Decodable {
	let id: Int
	let title: String
	let type: String
	let link: String
}
struct PriorityArticle: Identifiable, Decodable {
	let id: Int
	let title: String
	let excerpt: String
	let picture: String
	let permalink: String
	let date: Date
	let date_gmt: Date
	let primary_category: WpCategory
}
struct HpmWeather: Decodable {
	let icon: String
	let description: String
	let temperature: String
}
struct NowPlaying: Decodable {
	let radio: [NowPlayingStation]
	let tv: [NowPlayingStation]
}
struct NowPlayingStation: Decodable, Identifiable, Hashable {
	var id: Int
	var name: String
	var artist: String
	var title: String
	var album: String
}
struct PromosApiCall: Decodable {
	let code: String
	let message: String
	let data: PromoData
}
struct PromoData: Decodable {
	let promos: [Promo]
}
struct Promo: Decodable {
	var type: String
	var location: String
	var content: String
}
struct ArticleData: Decodable {
	let id: Int
	let status: String
	let date: Date
	let date_gmt: Date
	let modified_gmt: Date
	let link: String
	let title: ArticleDataRendered
	let excerpt: ArticleDataRendered
	let featured_media_url: String
}
struct ArticleDataRendered: Decodable {
	let rendered: String
}
struct Coauthor: Decodable {
	let display_name: String
	let user_nicename: String
	let guest_author: Bool
	var extra: CoauthorExtra?
}
struct CoauthorExtra: Decodable {
	var biography: String?
	var metadata: CoauthorMetadata?
}
struct CoauthorMetadata: Decodable {
	let title: String
	let pronouns: String
	let email: String
	let facebook: String
	let twitter: String
	let linkedin: String
	let phone: String
}
struct WpCategory: Encodable, Equatable, Decodable {
	let id: Int
	let name: String
	let slug: String
}
struct HpmCategories: Decodable {
	var articles: [Int: [ArticleData]]
}

func UpdateStreams() async throws -> Streams {
	let streams: Streams = try await URLSession.shared.decode(from: URL(string: "https://cdn.houstonpublicmedia.org/assets/streams.json")!)
	return streams
}
func UpdatePodcasts() async throws -> PodcastList {
	let podcasts: PodcastApiCall = try await URLSession.shared.decode(from: URL(string: "https://www.houstonpublicmedia.org/wp-json/hpm-podcast/v1/list")!)
	for podcast in podcasts.data.list {
		await CachePodcastArtwork(url: podcast.image.medium.url, filename: podcast.name.convertedToSlug() + ".webp")
	}
	return podcasts.data
}
func UpdatePriorityArticles() async throws -> PriorityArticleData {
	//let priorityArticles: PriorityApiCall = try await URLSession.shared.decode(from: URL(string: "https://www.houstonpublicmedia.org/wp-json/hpm-priority/v1/list")!)
	let priorityArticles: PriorityApiCall = try await URLSession.shared.decode(from: URL(string: "https://cdn.houstonpublicmedia.org/assets/promos-test.json")!)
	return priorityArticles.data
}
func UpdatePromos() async throws -> PromoData {
	let newPromoData: PromosApiCall = try await URLSession.shared.decode(from: URL(string: "https://www.houstonpublicmedia.org/wp-json/hpm-promos/v1/list")!)
	return newPromoData.data
}
func UpdateNowPlaying() async throws -> NowPlaying {
	let nowPlaying: NowPlaying = try await URLSession.shared.decode(from: URL(string: "https://cdn.houstonpublicmedia.org/assets/nowplay/all.json")!)
	return nowPlaying
}
func PullPodcastEpisodes(podcast: Podcast) async throws -> Podcast {
	var podTemp = podcast
	let download: PodcastDetailApiCall = try await URLSession.shared.decode(from: URL(string: podcast.feed_json)!)
	podTemp.episodelist = download.data.feed.items
	return podTemp
}
func UpdateCategoryArticles(id: Int) async throws -> [ArticleData] {
	let articles: [ArticleData] = try await URLSession.shared.decode(from: URL(string: "https://www.houstonpublicmedia.org/wp-json/wp/v2/posts/?categories=\(id)&per_page=5")!)
	return articles
}
func CategoryIds(categories: [WpCategory]) -> [Int] {
	var ids: [Int] = []
	for category in categories {
		ids.append(category.id)
	}
	return ids
}

func CachePodcastArtwork(url: String, filename: String) async {
	let fileManager: FileManager = FileManager.default
	let directory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
	var redownload: Bool = true
	let documentUrl = directory.appendingPathComponent(filename)
	if let attributes = try? FileManager.default.attributesOfItem(atPath: documentUrl.path) as [FileAttributeKey: Any],
		let modificationDate = attributes[FileAttributeKey.modificationDate] as? Date {
			let delta = modificationDate.distance(to: Date())
			if delta < 86400 {
				redownload = false
				print("\(filename) is less than a day old")
			}
		}
	
	// here check if file already exists on simulator
	if redownload {
		do {
			let imageData: Data = try Data(contentsOf: URL(string: url)!)
			try imageData.write(to: URL(fileURLWithPath: documentUrl.path))
			print("\(filename) saved successfully")
		} catch {
			print("Podcast episodes update failed with error \(error)")
		}
	}
}

func GetPodcastArtwork(filename: String) -> String? {
	let fileManager: FileManager = FileManager.default
	let directory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
	
	let documentUrl = directory.appendingPathComponent(filename)
	if fileManager.fileExists(atPath: (documentUrl.path)) {
		return documentUrl.path
	} else {
		return nil
	}
}

@MainActor class StationData: ObservableObject {
	@Published var streams = Streams(audio: [
		Station(
			id: 0,
			name: "News 88.7",
			type: "audio",
			artwork: "https://cdn.houstonpublicmedia.org/assets/images/ListenLive_News.png.webp",
			aacSource: "https://stream.houstonpublicmedia.org/news-aac",
			mp3Source: "https://stream.houstonpublicmedia.org/news-mp3",
			hlsSource: "https://hls.houstonpublicmedia.org/hpmnews/playlist.m3u8"
		),
		Station(
			id: 1,
			name: "Classical",
			type: "audio",
			artwork: "https://cdn.houstonpublicmedia.org/assets/images/ListenLive_Classical.png.webp",
			aacSource: "https://stream.houstonpublicmedia.org/classical-aac",
			mp3Source: "https://stream.houstonpublicmedia.org/classical-mp3",
			hlsSource: "https://hls.houstonpublicmedia.org/classical/playlist.m3u8"
		),
		Station(
			id: 2,
			name: "The Vibe",
			type: "audio",
			artwork: "https://cdn.houstonpublicmedia.org/assets/images/ListenLive_TheVibe.png.webp",
			aacSource: "https://stream.houstonpublicmedia.org/thevibe-aac",
			mp3Source: "https://stream.houstonpublicmedia.org/thevibe-mp3",
			hlsSource: "https://hls.houstonpublicmedia.org/thevibe/playlist.m3u8"
		)
	])
	@Published var podcasts = PodcastList(list:[])
	@Published var priorityData = PriorityArticleData(articles:[], breaking: BreakingNews(id: 0, title: "", type: "", link: ""), talkshow: "hello-houston", weather: HpmWeather(icon: "", description: "", temperature: ""))
	@Published var promos = PromoData(promos: [])
	@Published var nowPlaying = NowPlaying(radio: [
		NowPlayingStation(id: 0, name: "News 88.7", artist: "Houston Public Media News", title: "", album: "" ),
		NowPlayingStation(id: 1, name: "Classical", artist: "Houston Public Media Classical", title: "", album: "" ),
		NowPlayingStation(id: 2, name: "The Vibe from KTSU and HPM", artist: "The Vibe from KTSU and HPM", title: "", album: "" )
	], tv: [])
	@Published var categories = HpmCategories(articles: [:])
	
	func jsonPull() async {
		do {
			streams = try await UpdateStreams()
			podcasts = try await UpdatePodcasts()
			priorityData = try await UpdatePriorityArticles()
			promos = try await UpdatePromos()
			nowPlaying = try await UpdateNowPlaying()
		} catch {
			print("Initialization failed with error \(error)")
		}
	}
	func nowPlayPull() async {
		do {
			nowPlaying = try await UpdateNowPlaying()
		} catch {
			print("Now Playing Pull failed with error \(error)")
		}
	}
	
	func podcastPull(index: Int) async {
		do {
			podcasts.list[index] = try await PullPodcastEpisodes(podcast: podcasts.list[index])
		} catch {
			print("Podcast episodes update failed with error \(error)")
		}
	}
	
	func updateCategories(list: [WpCategory]) async {
		do {
			for category in list {
				categories.articles[category.id] = try await UpdateCategoryArticles(id: category.id)
			}
		} catch {
			print("Podcast episodes update failed with error \(error)")
		}
	}
}
