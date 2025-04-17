//
//  HpmStreams.swift
//  Houston Public Media
//
//  Created by Jared Counts on 10/16/24.
//
import Foundation

struct Streams: Decodable {
	let audio: [Station]
	let video: [Station]
	var nowPlayingFeed: String
}
struct Station: Decodable, Identifiable, Hashable {
	var id: Int
	var name: String
	var type: String
	var artwork: String
	var aacSource: String
	var mp3Source: String
	var hlsSource: String
	var dashSource: String
	var fairplayLicense: String
	var fairplayCertificate: String
	var widevineLicense: String
	var widevineCertificate: String
}
struct PodcastApiCall: Decodable {
	let code: String
	let message: String
	let data: PodcastList
}
struct PodcastList: Decodable {
	let list: [Podcast]
}
struct Podcast: Identifiable, Decodable {
	let id: Int
	let image: ImageCrops
	let latest_episode: PodcastEpisode
	let feed: String
	let archive: String
	let slug: String
	let name: String
	let description: String
	let feed_json: String
}
struct PodcastEpisode: Decodable {
	let audio: String
	let title: String
	let link: String
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
	let breaking: String
	let talkshow: String
}
struct PriorityArticle: Identifiable, Decodable {
	let id: Int
	let title: String
	let excerpt: String
	let picture: String
	let permalink: String
}
//struct NowPlaying: Decodable {
//	let radio: [NowPlayingStation]
//	let tv: [NowPlayingStation]
//}
//struct NowPlayingStation: Decodable, Identifiable, Hashable {
//	var id: Int
//	var name: String
//	var artist: String
//	var title: String
//	var album: String
//}
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

func UpdateStreams() async throws -> Streams {
	let streams: Streams = try await URLSession.shared.decode(from: URL(string: "https://s3-us-west-2.amazonaws.com/hpmwebv2/assets/streams.json?v=1")!)
	return streams
}
func UpdatePodcasts() async throws -> PodcastList {
	let podcasts: PodcastApiCall = try await URLSession.shared.decode(from: URL(string: "https://www.houstonpublicmedia.org/wp-json/hpm-podcast/v1/list")!)
	return podcasts.data
}
func UpdatePriorityArticles() async throws -> PriorityArticleData {
	let priorityArticles: PriorityApiCall = try await URLSession.shared.decode(from: URL(string: "https://www.houstonpublicmedia.org/wp-json/hpm-priority/v1/list")!)
	return priorityArticles.data
}
func UpdatePromos() async throws -> PromoData {
	let newPromoData: PromosApiCall = try await URLSession.shared.decode(from: URL(string: "https://www.houstonpublicmedia.org/wp-json/hpm-promos/v1/list")!)
	return newPromoData.data
}
//func UpdateNowPlaying() async throws -> NowPlaying {
//	let nowPlaying: NowPlaying = try await URLSession.shared.decode(from: URL(string: "https://s3-us-west-2.amazonaws.com/hpmwebv2/assets/nowplay/all.json")!)
//	return nowPlaying
//}

@MainActor class StationData: ObservableObject {
	@Published var streams = Streams(audio:[], video:[], nowPlayingFeed: "")
	@Published var podcasts = PodcastList(list:[])
	@Published var priorityData = PriorityArticleData(articles:[], breaking: "", talkshow: "")
	@Published var promos = PromoData(promos: [])
//	@Published var nowPlaying = NowPlaying(radio: [], tv: [])
	
	func jsonPull() async {
		do {
			streams = try await UpdateStreams()
			podcasts = try await UpdatePodcasts()
			priorityData = try await UpdatePriorityArticles()
			promos = try await UpdatePromos()
//			nowPlaying = try await UpdateNowPlaying()
		} catch {
			print("Initialization failed with error \(error)")
		}
	}
//	func nowPlayPull() async {
//		do {
//			nowPlaying = try await UpdateNowPlaying()
//		} catch {
//			print("Initialization failed with error \(error)")
//		}
//	}
}
