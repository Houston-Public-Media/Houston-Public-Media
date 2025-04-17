//
//  View-TabHeader.swift
//  HPM
//
//  Created by Jared Counts on 4/16/25.
//

import SwiftUI

struct TabHeaderView: View {
	var section: String
	var body: some View {
		ZStack {
			Color("HPM Red")
			Text(section)
				.font(.headline)
				.foregroundStyle(Color("HPM White"))
				.padding(.bottom, 5)
		}
		.frame(width: UIScreen.main.bounds.size.width, height: 25)
	}
}

#Preview {
	TabHeaderView(section: "Test")
}
