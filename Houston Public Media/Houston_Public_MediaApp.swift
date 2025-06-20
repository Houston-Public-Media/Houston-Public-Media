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
	@StateObject var audioManager = AudioManager()
	
    var body: some Scene {
        WindowGroup {
			ContentView()
			.environmentObject(hpmData)
			.environmentObject(audioManager)
        }
    }
}

extension TinyStorage {
	static let appGroup: TinyStorage = {
		return .init(insideDirectory: URL.documentsDirectory, name: "tiny-storage-general-prefs")
	}()
}
