//
//  Houston_Public_MediaApp.swift
//  Houston Public Media
//
//  Created by Jared Counts on 10/8/24.
//

import SwiftUI
import TinyStorage

@main
struct Houston_Public_MediaApp: App {
	@StateObject var hpmData = StationData()
	@StateObject var launchScreenState = LaunchScreenStateManager()
	@StateObject var audioManager = AudioManager()
	
    var body: some Scene {
        WindowGroup {
			ZStack {
				ContentView()
				if launchScreenState.state != .finished {
					LaunchScreenView()
				}
				
			}
			.environmentObject(hpmData)
			.environmentObject(launchScreenState)
			.environmentObject(audioManager)
        }
    }
}

extension TinyStorage {
	static let appGroup: TinyStorage = {
		return .init(insideDirectory: URL.documentsDirectory, name: "tiny-storage-general-prefs")
	}()
}
