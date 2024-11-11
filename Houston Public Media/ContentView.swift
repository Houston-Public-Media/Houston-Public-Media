//
//  ContentView.swift
//  Houston Public Media
//
//  Created by Jared Counts on 10/8/24.
//

import SwiftUI
import Blackbird

struct ContentView: View {
	@EnvironmentObject var hpmData: HpmStationData
	@EnvironmentObject private var launchScreenState: LaunchScreenStateManager
    var body: some View {
		VStack {
			NavigationStack {
				List {
					Section(header: Text("Podcasts")) {
						ForEach(hpmData.podcasts.list, id: \.slug) { podcast in
							NavigationLink {
								AsyncImage(url: URL(string: podcast.image.full.url)) { image in
									image.resizable()
								} placeholder: {
									ProgressView()
								}
								.frame(width: 250, height: 250)
								Text(podcast.name).font(.headline).multilineTextAlignment(.leading).padding(5)
								Text(podcast.description).padding(5)
							} label: {
								AsyncImage(url: URL(string: podcast.image.thumbnail.url)) { image in
									image.resizable()
								} placeholder: {
									ProgressView()
								}
								.frame(width: 50, height: 50)
								Text(podcast.name)
							}
						}
					}
					Section(header: Text("Top Stories")) {
						ForEach(hpmData.priorityArticles.articles, id: \.id) { article in
							NavigationLink {
								AsyncImage(url: URL(string: article.picture)!) { image in
									image.resizable().aspectRatio(contentMode: .fit)
								} placeholder: {
									ProgressView()
								}
								.frame(width: 300)
								Text(article.title).font(.headline)
								Text(article.excerpt)
								Text(article.permalink)
							} label: {
								AsyncImage(url: URL(string: article.picture)!) { image in
									image.resizable().aspectRatio(contentMode: .fit)
								} placeholder: {
									ProgressView()
								}
								.frame(width: 75)
								Text(article.title)
							}
						}
					}
				}
				.navigationTitle("HPM Main")
			}
			HpmPlayerView().frame(width: UIScreen.main.bounds.width, height: (UIScreen.main.bounds.width / 1.77778) + 50)
		}
		.task {
			await hpmData.jsonPull()
			try? await Task.sleep(for: Duration.seconds(1))
			self.launchScreenState.dismiss()
		}
	}
}

#Preview {
	ContentView().environmentObject(HpmStationData()).environmentObject(LaunchScreenStateManager())
}
