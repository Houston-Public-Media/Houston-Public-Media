//
//  View-TalkShow.swift
//  HPM
//
//  Created by Jared Counts on 4/16/25.
//

import SwiftUI

struct TalkShowView: View {
	@EnvironmentObject var playback: AudioManager
	var alert: String
	private var show: String
	private var showName: String
	private var accentColor: String
	private var textColor: String
	private var backgroundColor: String
	let station = Station(
		id: 0,
		name: "News 88.7",
		type: "audio",
		artwork: "https://cdn.houstonpublicmedia.org/assets/images/ListenLive_News.png.webp",
		aacSource: "https://stream.houstonpublicmedia.org/news-aac",
		mp3Source: "https://stream.houstonpublicmedia.org/news-mp3",
		hlsSource: "https://hls.houstonpublicmedia.org/hpmnews/playlist.m3u8"
	)
	init(alert: String) {
		self.alert = alert
		if alert == "hello-houston" {
			self.show = "hello-houston"
			self.showName = "Hello Houston"
			self.accentColor = "HPM Red"
			self.textColor = "HPM Black"
			self.backgroundColor = "HPM HH Orange"
		} else {
			self.show = "houston-matters"
			self.showName = "Houston Matters"
			self.accentColor = "HPM HH Orange"
			self.textColor = "HPM White"
			self.backgroundColor = "HPM HM Blue"
		}
	}
	var body: some View {
		HStack {
			Text(showName + " is on the air!")
				.font(.headline)
				.foregroundStyle(Color(textColor))
				.multilineTextAlignment(.leading)
			Spacer()
			Menu("Interact") {
				Button("Call", action: {
					guard let phoneNum = URL(string: "tel://1-713-440-8870") else {return}
					UIApplication.shared.open(phoneNum)
				})
				Button("Text", action: {
					guard let phoneNum = URL(string: "sms://1-713-440-8870") else {return}
					UIApplication.shared.open(phoneNum)
				})
				Button("Listen", action: {
					if playback.state == .playing {
						playback.pause()
					}
					playback.startAudio(audioType: .stream, station: station)
					playback.state = .playing
					playback.currentStation = station.id
					playback.audioType = .stream
				})
				if show == "hello-houston" {
					Button("Watch", action: {
						guard let youtube = URL(string: "https://www.youtube.com/@HoustonPublicMedia/streams") else {return}
						UIApplication.shared.open(youtube)
					})
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
	TalkShowView(alert: "hello-houston").environmentObject(AudioManager())
}
