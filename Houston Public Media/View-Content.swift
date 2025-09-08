//
//  ContentView.swift
//  Houston Public Media
//
//  Created by Jared Counts on 10/8/24.
//

import SwiftUI

struct ContentView: View {
	@EnvironmentObject var hpmData: StationData
	@EnvironmentObject var playback: AudioManager
	@State private var selectedTab: Int = 0
    var body: some View {
		VStack {
			HStack {
				Image("HPM Bat Logo")
					.resizable()
					.scaledToFit()
					.frame(maxHeight: 36)
				Spacer()
				Link("Donate", destination: URL(string: "https://www.houstonpublicmedia.org/donate")!)
					.buttonStyle(.borderedProminent)
					.foregroundStyle(Color("HPM White"))
					.tint(Color("HPM Red"))
			}
				.padding(.horizontal)
			HStack {
				Text(currentDate())
					.font(.system(size: 11, weight: .bold))
					.foregroundStyle(Color("HPM White"))
				Spacer()
				HStack {
					Text(hpmData.priorityData.weather.temperature.htmlUnescape())
						.font(.system(size: 11, weight: .bold))
						.foregroundStyle(Color("HPM White"))
					if hpmData.priorityData.weather.icon != "" {
						AsyncImage(url: URL(string: hpmData.priorityData.weather.icon)!) { image in
							image
								.resizable()
								.aspectRatio(contentMode: .fit)
						} placeholder: {
							ProgressView()
						}
						.frame(width: 15)
					}
				}
			}
				.padding(EdgeInsets(top: 4, leading: 12, bottom: 0, trailing: 12))
			TabView(selection: $selectedTab) {
				Group {
					NavigationStack {
						TodayView(data: _hpmData, playback: _playback, selectedTab: $selectedTab)
					}
						.tabItem {
							Label("Today", systemImage: "newspaper")
						}
						.tag(0)
					NavigationStack {
						ListenView(data: _hpmData, playback: _playback)
					}
						.tabItem {
							Label("Listen", systemImage: "play.circle.fill")
						}
						.tag(1)
					NavigationStack {
						WatchView(data: _hpmData)
					}
						.tabItem {
							Label("Watch", systemImage: "tv")
						}
						.tag(2)
					NavigationStack {
						SettingsView()
					}
						.tabItem {
							Label("Settings", systemImage: "gear")
						}
						.tag(3)
				}
			}
			.tabViewBottomAccessory(content: {
				if playback.state != .stopped {
					AudioPlayerView(data: _hpmData, playback: _playback)
				}
			})
			.tabBarMinimizeBehavior(.never)
		}
			.task {
				await hpmData.jsonPull()
				repeat {
					await hpmData.nowPlayPull()
					try? await Task.sleep(for: .seconds(60))
				} while (!Task.isCancelled)
			}
			.background(Color("HPM Blue Secondary"))
	}
}

#Preview {
	ContentView()
		.environmentObject(StationData())
		.environmentObject(AudioManager())
}
