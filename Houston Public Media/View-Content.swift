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
					.frame(maxHeight: 16)
				Spacer()
				Link("Donate", destination: URL(string: "https://www.houstonpublicmedia.org/donate")!)
					.foregroundColor(Color("HPM White"))
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
