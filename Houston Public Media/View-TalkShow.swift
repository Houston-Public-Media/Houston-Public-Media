//
//  View-TalkShow.swift
//  HPM
//
//  Created by Jared Counts on 4/16/25.
//

import SwiftUI

struct TalkShowView: View {
	@EnvironmentObject var playback: AudioManager
	var alert: TalkShows
	private var show: String
	private var showName: String
	private var accentColor: String
	private var textColor: String
	private var backgroundColor: String
	private var email: String
	private var streamId: String
	let station = Station(
		id: 0,
		name: "News 88.7",
		type: "audio",
		artwork: "https://cdn.houstonpublicmedia.org/assets/images/ListenLive_News.png.webp",
		aacSource: "https://stream.houstonpublicmedia.org/news-aac",
		mp3Source: "https://stream.houstonpublicmedia.org/news-mp3",
		hlsSource: "https://hls.houstonpublicmedia.org/hpmnews/playlist.m3u8"
	)
	init(alert: TalkShows) {
		self.alert = alert
		if alert.hellohouston.live == true {
			self.show = "hello-houston"
			self.showName = "Hello Houston"
			self.accentColor = "HPM Red"
			self.textColor = "HPM Black"
			self.backgroundColor = "HPM HH Orange"
			self.email = "mailto:hello@hellohouston.org"
			self.streamId = alert.hellohouston.id
		} else {
			self.show = "houston-matters"
			self.showName = "Houston Matters"
			self.accentColor = "HPM HM Green"
			self.textColor = "HPM White"
			self.backgroundColor = "HPM HM Blue"
			self.email = "mailto:talk@houstonmatters.org"
			self.streamId = alert.houstonmatters.id
		}
	}
	var body: some View {
		HStack {
			Text(showName + " is live!")
				.font(.headline)
				.foregroundStyle(Color(textColor))
				.multilineTextAlignment(.leading)
			Spacer()
			Menu("Interact") {
				Button(action: {
					guard let youtube = URL(string: "https://www.youtube.com/watch?v=" + streamId) else {return}
					UIApplication.shared.open(youtube)
				}) {
					Label("Watch", systemImage: "tv")
				}
				Button(action: {
					if playback.state == .playing {
						playback.pause()
					}
					playback.startAudio(audioType: .stream, station: station)
					playback.state = .playing
					playback.currentStation = station.id
					playback.audioType = .stream
				}) {
					Label("Listen", systemImage: "headphones")
				}
				Button(action: {
					guard let phoneNum = URL(string: "tel://1-713-440-8870") else {return}
					UIApplication.shared.open(phoneNum)
				}) {
					Label("Call", systemImage: "phone.fill")
				}
				Button(action: {
					guard let phoneNum = URL(string: "sms://1-713-440-8870") else {return}
					UIApplication.shared.open(phoneNum)
				}) {
					Label("Text", systemImage: "message.fill")
				}
				Button(action: {
					guard let emailLink = URL(string: email) else {return}
					UIApplication.shared.open(emailLink)
				}) {
					Label("Email", systemImage: "envelope.fill")
				}
			}
			.buttonStyle(.borderedProminent)
			.foregroundStyle(Color("HPM White"))
			.tint(Color(accentColor))
		}
			.padding(.horizontal, 8)
			.padding(.vertical, 0)
			.frame(height: 40)
			.listRowBackground(Color(backgroundColor))
	}
}

#Preview {
	TalkShowView(alert: TalkShows(houstonmatters: TalkShowDetail(live: false, id: "", title: "", embed: "", description: ""), hellohouston: TalkShowDetail(live: true, id: "", title: "", embed: "", description: ""))).environmentObject(AudioManager())
}
