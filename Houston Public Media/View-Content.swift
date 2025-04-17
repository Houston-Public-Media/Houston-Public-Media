//
//  ContentView.swift
//  Houston Public Media
//
//  Created by Jared Counts on 10/8/24.
//

import SwiftUI

struct ContentView: View {
	@EnvironmentObject var hpmData: StationData
	@EnvironmentObject private var launchScreenState: LaunchScreenStateManager
	@EnvironmentObject var playback: AudioManager
	@State private var selectedTab: Int = 0
    var body: some View {
		VStack {
			HStack {
				Image("HPM Wordmark")
					.resizable()
					.scaledToFit()
					.frame(width: (UIScreen.main.bounds.size.width / 2))
				Spacer()
				Link("Donate", destination: URL(string: "https://www.houstonpublicmedia.org/donate")!)
					.foregroundColor(Color("HPM White"))
			}
				.padding(.horizontal)
			TabView(selection: $selectedTab) {
				Group {
					TodayView(data: _hpmData, playback: _playback, selectedTab: $selectedTab)
						.tabItem {
							Label("Today", systemImage: "newspaper")
						}
						.tag(0)
					ListenView(data: _hpmData, playback: _playback)
						.tabItem {
							Label("Listen", systemImage: "play.circle.fill")
						}
						.tag(1)
					WatchView(data: _hpmData)
						.tabItem {
							Label("Watch", systemImage: "tv")
						}
						.tag(2)
					SettingsView()
						.tabItem {
							Label("Settings", systemImage: "gear")
						}
						.tag(3)
				}
				.toolbar {
					if playback.state != .stopped {
						ToolbarItem(placement: .bottomBar) {
							AudioPlayerView(data: _hpmData, playback: _playback)
						}
					}
				}
			}
		}
			.task {
				await hpmData.jsonPull()
				try? await Task.sleep(for: Duration.seconds(1))
				self.launchScreenState.dismiss()
				repeat {
					await hpmData.nowPlayPull()
					try? await Task.sleep(for: .seconds(60))
				} while (!Task.isCancelled)
			}
			.handleOpenURLInApp()
			.background(Color("HPM Red"))
	}
}

#Preview {
	ContentView()
		.environmentObject(StationData())
		.environmentObject(LaunchScreenStateManager())
		.environmentObject(AudioManager())
}
