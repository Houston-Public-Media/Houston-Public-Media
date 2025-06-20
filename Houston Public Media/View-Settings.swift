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
		List {
			NavigationLink {
				let allCategories = [
					WpCategory(id: 3, name: "Arts & Culture", slug: "arts-culture"),
					WpCategory(id: 2, name: "All News", slug: "news"),
					WpCategory(id: 32566, name: "City of Houston", slug: "city-of-houston"),
					WpCategory(id: 51718, name: "Courts", slug: "courts"),
					WpCategory(id: 10, name: "Education", slug: "education"),
					WpCategory(id: 14, name: "Energy & Environment", slug: "energy-environment"),
					WpCategory(id: 58671, name: "Fort Bend", slug: "fort-bend"),
					WpCategory(id: 32567, name: "Harris County", slug: "harris-county"),
					WpCategory(id: 16, name: "Health & Science", slug: "health-science"),
					WpCategory(id: 51851, name: "Housing", slug: "housing"),
					WpCategory(id: 29328, name: "inDepth", slug: "indepth"),
					WpCategory(id: 52248, name: "Infrastructure", slug: "infrastructure"),
					WpCategory(id: 2113, name: "Local News", slug: "local"),
					WpCategory(id: 20, name: "Politics", slug: "politics"),
					WpCategory(id: 3340, name: "Sports", slug: "sports"),
					WpCategory(id: 22, name: "Texas", slug: "texas"),
					WpCategory(id: 18, name: "Transportation", slug: "transportation"),
					WpCategory(id: 2232, name: "Weather", slug: "weather")
				]
				let selectedCategories = CategoryIds(categories: categories)
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
				.toolbar {
					EditButton()
				}
			} label: {
				Label("Category Selection", systemImage: "list.bullet")
			}
			NavigationLink {
				List {
					HStack {
						Text("Call Houston Public Media")
						Spacer()
						Button(action: {
							guard let phoneNum = URL(string: "tel://1-713-748-8888") else {return}
							UIApplication.shared.open(phoneNum)
						}) {
							Text("Call")
						}
						.buttonStyle(.borderedProminent)
						.foregroundStyle(Color("HPM White"))
						.tint(Color("HPM Red"))
					}
					HStack {
						Text("Call Member Services")
						Spacer()
						Button(action: {
							guard let phoneNum = URL(string: "tel://1-713-743-8483") else {return}
							UIApplication.shared.open(phoneNum)
						}) {
							Text("Call")
						}
						.buttonStyle(.borderedProminent)
						.foregroundStyle(Color("HPM White"))
						.tint(Color("HPM Red"))
					}
					HStack {
						Text("Email Member Services")
						Spacer()
						Button(action: {
							guard let mail = URL(string: "mailto:membership@houstonpublicmedia.org?subject=HPM%20Member%20Services%20Query") else {return}
							UIApplication.shared.open(mail)
						}) {
							Text("Email")
						}
						.buttonStyle(.borderedProminent)
						.foregroundStyle(Color("HPM White"))
						.tint(Color("HPM Red"))
					}
					HStack {
						VStack {
							Text("Mailing Address")
								.fontWeight(.bold)
								.frame(maxWidth: .infinity, alignment: .leading)
							Text("4343 Elgin Street")
								.frame(maxWidth: .infinity, alignment: .leading)
							Text("Houston, TX 77204")
								.frame(maxWidth: .infinity, alignment: .leading)
						}
						Spacer()
						Button(action: {
							guard let maps = URL(string: "maps://?q=4343+Elgin+St+Houston+TX+77204") else {return}
							UIApplication.shared.open(maps)
						}) {
							Text("View Map")
						}
						.buttonStyle(.borderedProminent)
						.foregroundStyle(Color("HPM White"))
						.tint(Color("HPM Red"))
					}
				}
				.padding(.horizontal, 8)
			} label: {
				Label("Contact Us", systemImage: "phone.arrow.up.right")
			}
			NavigationLink {
				Text("Made with ❤️ by Houston Public Media")
				Text("App Version: 0.1")
			} label: {
				Label("About", systemImage: "questionmark.folder")
			}
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
