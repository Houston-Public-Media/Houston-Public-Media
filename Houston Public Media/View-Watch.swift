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
		WebView(payload: "https://cdn.houstonpublicmedia.org/assets/watch-live.html", viewType: .url)
			.frame(minWidth: 0, maxWidth: .infinity, minHeight: 300, maxHeight: .infinity)
	}
}

#Preview {
	WatchView().environmentObject(StationData())
}
