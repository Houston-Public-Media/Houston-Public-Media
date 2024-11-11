//
//  Houston_Public_MediaApp.swift
//  Houston Public Media
//
//  Created by Jared Counts on 10/8/24.
//

import SwiftUI
import AVFoundation
import AVKit
import Blackbird

@main
struct Houston_Public_MediaApp: App {
	@StateObject var hpmData = HpmStationData()
	@StateObject var launchScreenState = LaunchScreenStateManager()
	let database = try! Blackbird.Database(path: prepareDatabaseFile())
    var body: some Scene {
        WindowGroup {
			ZStack {
				ContentView()
				if launchScreenState.state != .finished {
					LaunchScreenView()
				}
				
			}.environmentObject(hpmData).environmentObject(launchScreenState).environment(\.blackbirdDatabase, database)
        }
    }
}

extension URLSession {
	func decode<T: Decodable>(
		_ type: T.Type = T.self,
		from url: URL,
		keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
		dataDecodingStrategy: JSONDecoder.DataDecodingStrategy = .deferredToData,
		dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate
	) async throws  -> T {
		let (data, _) = try await data(from: url)

		let decoder = JSONDecoder()
		decoder.keyDecodingStrategy = keyDecodingStrategy
		decoder.dataDecodingStrategy = dataDecodingStrategy
		decoder.dateDecodingStrategy = dateDecodingStrategy

		let decoded = try decoder.decode(T.self, from: data)
		return decoded
	}
}

func prepareDatabaseFile() -> String {
	let fileName: String = "HpmData.sqlite"

	let fileManager:FileManager = FileManager.default
	let directory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!

	let documentUrl = directory.appendingPathComponent(fileName)
	let bundleUrl = Bundle.main.resourceURL?.appendingPathComponent(fileName)

	// here check if file already exists on simulator
	if fileManager.fileExists(atPath: (documentUrl.path)) {
		print("document file exists!")
		return documentUrl.path
	} else if fileManager.fileExists(atPath: (bundleUrl?.path)!) {
		print("document file does not exist, copy from bundle!")
		do {
			try fileManager.copyItem(at:bundleUrl!, to:documentUrl)
		} catch {
			print("error copying file from bundle: \(error)")
		}
		
	}

	return documentUrl.path
}
