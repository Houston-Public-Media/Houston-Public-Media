//
//  View-Settings.swift
//  HPM
//
//  Created by Jared Counts on 4/8/25.
//

import SwiftUI
import TinyStorage

struct SettingsView: View {
	@TinyStorageItem("categories", storage: .appGroup)
	var categories: [WpCategory] = []
	var body: some View {
		let allCategories = [
			WpCategory(id: 3, name: "Arts & Culture"),
			WpCategory(id: 2, name: "All News"),
			WpCategory(id: 32566, name: "City of Houston"),
			WpCategory(id: 51718, name: "Courts"),
			WpCategory(id: 10, name: "Education"),
			WpCategory(id: 14, name: "Energy & Environment"),
			WpCategory(id: 58671, name: "Fort Bend"),
			WpCategory(id: 32567, name: "Harris County"),
			WpCategory(id: 16, name: "Health & Science"),
			WpCategory(id: 51851, name: "Housing"),
			WpCategory(id: 29328, name: "inDepth"),
			WpCategory(id: 52248, name: "Infrastructure"),
			WpCategory(id: 2113, name: "Local News"),
			WpCategory(id: 20, name: "Politics"),
			WpCategory(id: 3340, name: "Sports"),
			WpCategory(id: 22, name: "Texas"),
			WpCategory(id: 18, name: "Transportation"),
			WpCategory(id: 2232, name: "Weather"),
			WpCategory(id: 5, name: "All Shows"),
			WpCategory(id: 64721, name: "Hello Houston"),
			WpCategory(id: 58, name: "Houston Matters"),
			WpCategory(id: 11524, name: "Party Politics")
		]
		let selectedCategories = CategoryIds(categories: categories)
		VStack(spacing: 0) {
			TabHeaderView(section: "Settings")
			NavigationStack {
				List {
					Section(header: Text("Selected Categories")) {
						ForEach(categories, id: \.id) { category in
							HStack {
								Text(category.name)
							}
							.swipeActions(edge: .trailing) {
								Button(role: .destructive) {
									if let index = categories.firstIndex(of: category) {
										categories.remove(at: index)
									}
								} label: {
									Label("Delete", systemImage: "trash")
								}
							}
						}
						.onMove(perform: move)
					}
					.headerProminence(.increased)
					Section(header: Text("All Categories")) {
						ForEach(allCategories, id: \.id) { category in
							Button(action: {
								print("Category toggled: \(category.name)")
								categories = categoryToggle(category: category)
							}, label: {
								HStack {
									Text(category.name)
									if selectedCategories.contains(category.id) {
										Spacer()
										Image(systemName: "checkmark")
									}
								}
							})
						}
					}
					.headerProminence(.increased)
				}
				.toolbar{
					EditButton()
				}
			}
				.border(width: 1, edges: [.top], color: .gray)
		}
	}
	
	func categoryToggle(category: WpCategory) -> [WpCategory] {
		var categories = categories
		if let index = categories.firstIndex(of: category) {
			categories.remove(at: index)
		} else {
			categories.append(category)
		}
		return categories
	}
	
	func move(from source: IndexSet, to destination: Int) {
		categories.move(fromOffsets: source, toOffset: destination)
	}
}

#Preview {
	SettingsView()
}
