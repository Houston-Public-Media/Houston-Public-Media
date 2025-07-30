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
			TabView(selection: $selectedTab) {
				Group {
					NavigationStack {
						TodayView(data: _hpmData, playback: _playback, selectedTab: $selectedTab)
							.navigationTitle("Today")
							.navigationBarTitleDisplayMode(.inline)
					}
						.tabItem {
							Label("Today", systemImage: "newspaper")
						}
						.tag(0)
					NavigationStack {
						ListenView(data: _hpmData, playback: _playback)
							.navigationTitle("Listen")
							.navigationBarTitleDisplayMode(.inline)
					}
						.tabItem {
							Label("Listen", systemImage: "play.circle.fill")
						}
						.tag(1)
					NavigationStack {
						WatchView(data: _hpmData)
							.navigationTitle("Watch")
							.navigationBarTitleDisplayMode(.inline)
					}
						.tabItem {
							Label("Watch", systemImage: "tv")
						}
						.tag(2)
					NavigationStack {
						SettingsView()
							.navigationTitle("Settings")
							.navigationBarTitleDisplayMode(.inline)
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
			.tabBarMinimizeBehavior(.onScrollDown)
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
