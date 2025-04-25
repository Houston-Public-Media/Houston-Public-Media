//
//  HpmReadingView.swift
//  HPM
//
//  Created by Jared Counts on 11/12/24.
//

import SwiftUI
import TinyStorage

struct TodayView: View {
    @EnvironmentObject var data: StationData
	@EnvironmentObject var playback: AudioManager
	@Binding var selectedTab: Int
	@TinyStorageItem("categories", storage: .appGroup)
	var categories: [WpCategory] = []
	var body: some View {
		List {
			if !data.priorityData.breaking.isEmpty || !data.priorityData.talkshow.isEmpty {
				if !data.priorityData.breaking.isEmpty {
					Text(.init(data.priorityData.breaking.htmlToMarkDown()))
						.font(.headline)
						.foregroundStyle(Color("HPM White"))
						.listRowBackground(Color("HPM Red"))
				}
				if !data.priorityData.talkshow.isEmpty {
					TalkShowView(alert: data.priorityData.talkshow)
				}
			}
			Section(header: Text("Top Stories")) {
				ScrollView(.horizontal) {
					HStack(spacing: 15) {
						ForEach(data.priorityData.articles, id: \.id) { article in
							ZStack {
								Color.white
									.cornerRadius(8)
								VStack {
									AsyncImage(url: URL(string: article.picture)!) { image in
										image
											.resizable()
											.aspectRatio(1.5, contentMode: .fit)
											.cornerRadius(8)
											.padding(8)
									} placeholder: {
										ProgressView()
									}
									Link(destination: URL(string: article.permalink)!, label: {
										Text(article.title)
											.font(.system(size: 18, weight: .regular))
											.multilineTextAlignment(.leading)
									})
										.frame(maxWidth: .infinity, alignment: .leading)
										.padding(.bottom, 3)
										.padding(.horizontal, 8)
										.tint(Color("HPM Gray"))
									Spacer()
									HStack {
										Text(wpDateFormatter(date: article.date_gmt))
											.font(.system(size: 11, weight: .regular))
										Spacer()
										Image(systemName: "arrow.up.right").accessibilityLabel("Open article")
									}
									.padding(.horizontal, 8)
									.padding(.bottom, 5)
								}
							}
								.frame(width: 300, height: 325)
								.shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 0)
								.padding(.vertical, 10)
								.padding(.horizontal, 3)
						}
					}
				}
			}
				.padding(.horizontal, 0)
				.headerProminence(.increased)
				.listRowBackground(Color.clear)
			if categories.isEmpty {
				Button("Selected Categories in Settings Pane") {
					selectedTab = 3
				  }
			} else {
				ForEach(categories, id: \.id) { category in
					Section(header: Text(category.name)) {
						ForEach(data.categories.articles[category.id] ?? [], id: \.id) { article in
							Link(destination: URL(string: article.link)!, label: {
								HStack {
									if article.featured_media_url != "" {
										AsyncImage(url: URL(string: article.featured_media_url)!) { image in
											image
												.resizable()
												.aspectRatio(contentMode: .fit)
										} placeholder: {
											ProgressView()
										}
										.frame(width: 75)
									}
									VStack {
										Text(article.title.rendered.htmlUnescape())
											.font(.system(size: 16, weight: .regular))
											.frame(maxWidth: .infinity, alignment: .leading)
											.padding(.bottom, 3)
										Text(wpDateFormatter(date: article.date_gmt))
											.font(.system(size: 11, weight: .regular))
											.frame(maxWidth: .infinity, alignment: .leading)
									}
									Image(systemName: "arrow.up.right").accessibilityLabel("Open article")
								}
							})
								.tint(Color("HPM Gray"))
						}
					}
					.headerProminence(.increased)
					.padding(.horizontal, 5)
				}
			}
		}
			.listStyle(GroupedListStyle())
			.handleOpenURLInApp()
			.task {
				await data.jsonPull()
				await data.updateCategories(list: categories)
			}
			.refreshable {
				await data.jsonPull()
				await data.updateCategories(list: categories)
			}
	}
}

#Preview {
	TodayView(selectedTab: .constant(0)).environmentObject(StationData())
}
