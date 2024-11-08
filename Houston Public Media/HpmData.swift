//
//  HpmStreams.swift
//  Houston Public Media
//
//  Created by Jared Counts on 10/16/24.
//
import Foundation
import Blackbird

struct HpmStreams: Decodable {
	let stations: [Streams]
}
struct Streams: BlackbirdModel {
	@BlackbirdColumn var id: Int
	@BlackbirdColumn var name: String
	@BlackbirdColumn var type: String
	@BlackbirdColumn var artwork: String
	@BlackbirdColumn var aacSource: String
	@BlackbirdColumn var mp3Source: String
	@BlackbirdColumn var hlsSource: String
	@BlackbirdColumn var dashSource: String
	@BlackbirdColumn var fairplayLicense: String
	@BlackbirdColumn var fairplayCertificate: String
	@BlackbirdColumn var widevineLicense: String
	@BlackbirdColumn var widevineCertificate: String
}
struct HpmPodcastApiCall: Decodable {
	let code: String
	let message: String
	let data: HpmPodcastList
}
struct HpmPodcastList: Decodable {
	let list: [HpmPodcast]
}
struct HpmPodcast: Decodable {
	let id: Int
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
}

func UpdateStreams() async throws -> HpmStreams {
	let streams: HpmStreams = try await URLSession.shared.decode(from: URL(string: "https://hpmwebv2.s3.us-west-2.amazonaws.com/assets/streams.json")!)
	return streams
}
func UpdatePodcasts() async throws -> HpmPodcastList {
	let podcasts: HpmPodcastApiCall = try await URLSession.shared.decode(from: URL(string: "https://www.houstonpublicmedia.org/wp-json/hpm-podcast/v1/list")!)
	return podcasts.data
}
func UpdatePriorityArticles() async throws -> HpmPriorityArticleData {
	let priorityArticles: HpmPriorityApiCall = try await URLSession.shared.decode(from: URL(string: "https://www.houstonpublicmedia.org/wp-json/hpm-priority/v1/list")!)
	return priorityArticles.data
}

@MainActor class HpmStationData: ObservableObject {
	@Published var streams = HpmStreams(stations:[])
	@Published var podcasts = HpmPodcastList(list:[])
	@Published var priorityArticles = HpmPriorityArticleData(articles:[])
	
	func jsonPull() async {
		do {
			streams = try await UpdateStreams()
			podcasts = try await UpdatePodcasts()
			priorityArticles = try await UpdatePriorityArticles()
		} catch {
			print("Initialization failed with error \(error)")
		}
	}
}
