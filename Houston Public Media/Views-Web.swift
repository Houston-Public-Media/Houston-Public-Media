//
//  HpmWebView.swift
//  HPM
//
//  Created by Jared Counts on 11/15/24.
//
import Foundation
import SwiftUI
import WebKit
import SafariServices

struct WebView: UIViewRepresentable {
	var payload: String
	let viewType: FilterType
	enum FilterType {
		case string, file, url
	}
   
	func makeUIView(context: Context) -> WKWebView {
		let webview: WKWebView = {
			let configuration = WKWebViewConfiguration()
			configuration.mediaTypesRequiringUserActionForPlayback = []
			configuration.allowsInlineMediaPlayback = true
			configuration.allowsPictureInPictureMediaPlayback = true
			return WKWebView(frame: .zero, configuration: configuration)
		}()
		webview.isInspectable = true
		webview.customUserAgent = "Jared's Super Cool iPhone iOS iPad Safari Thingy"
		return webview
	}

	func updateUIView(_ uiView: WKWebView, context: Context) {
		switch viewType {
			case .string:
				uiView.loadHTMLString(payload, baseURL: nil)
			case .file:
				let payloadArr = payload.split(separator: ".")
				var request = URLRequest(url: Bundle.main.url(forResource: String(payloadArr[0]), withExtension: String(payloadArr[1]))!)
				request.setValue("encrypted-media=*;geolocation=*;fullscreen=*;picture-in-picture=*", forHTTPHeaderField: "Permissions-Policy")
				uiView.load(request)
			case .url:
				var request = URLRequest(url: URL(string: payload)!)
				request.setValue("encrypted-media=*;geolocation=*;fullscreen=*;picture-in-picture=*", forHTTPHeaderField: "Permissions-Policy")
				uiView.load(request)
		}
	}
}

struct SFSafariView: UIViewControllerRepresentable {
	let url: URL

	func makeUIViewController(context: UIViewControllerRepresentableContext<Self>) -> SFSafariViewController {
		let sfvc = SFSafariViewController(url: url)
		sfvc.configuration.barCollapsingEnabled = true
		sfvc.configuration.entersReaderIfAvailable = false
		return sfvc
	}

	func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SFSafariView>) {
		// No need to do anything here
	}
}

private struct SafariViewControllerViewModifier: ViewModifier {
	@State private var urlToOpen: URL?

	func body(content: Content) -> some View {
		content
			.environment(\.openURL, OpenURLAction { url in
				/// Catch any URLs that are about to be opened in an external browser.
				/// Instead, handle them here and store the URL to reopen in our sheet.
				urlToOpen = url
				return .handled
			})
			.sheet(isPresented: $urlToOpen.mappedToBool(), onDismiss: {
				urlToOpen = nil
			}, content: {
				SFSafariView(url: urlToOpen!)
			})
	}
}

extension Binding where Value == Bool {
	init(binding: Binding<(some Any)?>) {
		self.init(
			get: {
				binding.wrappedValue != nil
			},
			set: { newValue in
				guard newValue == false else { return }

				// We only handle `false` booleans to set our optional to `nil`
				// as we can't handle `true` for restoring the previous value.
				binding.wrappedValue = nil
			}
		)
	}
}

extension Binding {
	/// Maps an optional binding to a `Binding<Bool>`.
	/// This can be used to, for example, use an `Error?` object to decide whether or not to show an
	/// alert, without needing to rely on a separately handled `Binding<Bool>`.
	func mappedToBool<Wrapped>() -> Binding<Bool> where Value == Wrapped? {
		Binding<Bool>(binding: self)
	}
}

extension View {
	/// Monitor the `openURL` environment variable and handle them in-app instead of via
	/// the external web browser.
	/// Uses the `SafariViewWrapper` which will present the URL in a `SFSafariViewController`.
	func handleOpenURLInApp() -> some View {
		modifier(SafariViewControllerViewModifier())
	}
}
