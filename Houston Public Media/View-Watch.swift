//
//  HpmWatchView.swift
//  HPM
//
//  Created by Jared Counts on 11/12/24.
//

import SwiftUI

struct WatchView: View {
	@EnvironmentObject var data: StationData
	@State private var selection = 0
	var body: some View {
		VStack(spacing: 0) {
			TabHeaderView(section: "Watch")
			WebView(payload: "watch-live.html", viewType: .file)
				.frame(minWidth: 0, maxWidth: .infinity, minHeight: 300, maxHeight: .infinity)
				.border(width: 1, edges: [.top], color: .gray)
		}
	}
}

#Preview {
	WatchView().environmentObject(StationData())
}
