//
//  HpmPlayer.swift
//  Houston Public Media
//
//  Created by Jared Counts on 11/8/24.
//
import AVFoundation
import AVKit
import SwiftUI
import Blackbird

struct HpmPlayerView: View {
	@BlackbirdLiveModels({ try await Streams.read(from: $0, orderBy: .ascending(\.$id)) }) var streams
	@State private var selection = 0
	var body: some View {
		if streams.didLoad {
			VStack {
				VideoPlayerView(streams: streams.results, stationId: $selection).frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width / 1.777778)
				HStack {
					Image(systemName: "play")
					Picker("Select Station", selection: $selection) {
						ForEach(streams.results) { stream in
							HStack {
								if stream.type == "video" {
									Image(systemName: "tv")
								} else {
									Image(systemName: "radio")
								}
								Text(stream.name).tag(stream.id)
							}
						}
					}
				}
			}
		}
	}
}

struct VideoPlayerView: UIViewControllerRepresentable {
	var streams: [Streams]
	@Binding var stationId: Int
	func makeUIViewController(context: Context) -> AVPlayerViewController {
		let name = streams[stationId].name
		let videoURL = URL(string: streams[stationId].hlsSource)!
		let fairplayLicense = streams[stationId].fairplayLicense
		let asset = Asset(name: name, url: videoURL)
		if fairplayLicense != "" {
			ContentKeyManager.sharedManager.createContentKeySession()
			asset.addAsContentKeyRecipient()
			ContentKeyManager.sharedManager.licensingServiceUrl = streams[stationId].fairplayLicense
			ContentKeyManager.sharedManager.fpsCertificateUrl = streams[stationId].fairplayCertificate
			ContentKeyManager.sharedManager.asset = asset
		}
		let player = AVPlayer(playerItem: AVPlayerItem(asset: asset.urlAsset))
		let playerController = AVPlayerViewController()
		playerController.player = player
		playerController.allowsPictureInPicturePlayback = true
		playerController.canStartPictureInPictureAutomaticallyFromInline = true
		playerController.showsPlaybackControls = true
		//player.play()
		return playerController
	}
	func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
		let name = streams[stationId].name
		let videoURL = URL(string: streams[stationId].hlsSource)!
		let fairplayLicense = streams[stationId].fairplayLicense
		let asset = Asset(name: name, url: videoURL)
		if fairplayLicense != "" {
			ContentKeyManager.sharedManager.createContentKeySession()
			asset.addAsContentKeyRecipient()
			ContentKeyManager.sharedManager.licensingServiceUrl = streams[stationId].fairplayLicense
			ContentKeyManager.sharedManager.fpsCertificateUrl = streams[stationId].fairplayCertificate
			ContentKeyManager.sharedManager.asset = asset
		}
		let player = AVPlayer(playerItem: AVPlayerItem(asset: asset.urlAsset))
		uiViewController.player = player
	}

}
