import GoogleMobileAds
import SwiftUI

struct GoogleBannerContentView: View {
  var body: some View {
	// Request an anchored adaptive banner with a width of 375.
	let adSize = currentOrientationAnchoredAdaptiveBanner(width: 375)
	GoogleBannerViewContainer(adSize)
	  .frame(width: adSize.size.width, height: adSize.size.height)
  }
}

struct GoogleBannerContentView_Previews: PreviewProvider {
	static var previews: some View {
		GoogleBannerContentView()
	}
}

private struct GoogleBannerViewContainer: UIViewRepresentable {
	typealias UIViewType = BannerView
	let adSize: AdSize

	init(_ adSize: AdSize) {
		self.adSize = adSize
		MobileAds.shared.requestConfiguration.testDeviceIdentifiers = [ "0fc3d49b2e5dd50f251a6c7204eeacab" ]
		MobileAds.shared.start()
	}

	func makeUIView(context: Context) -> BannerView {
		let banner = BannerView(adSize: adSize)
		banner.adUnitID = "/21775744923/example/adaptive-banner"
		banner.load(Request())
		banner.delegate = context.coordinator
		return banner
	}

	func updateUIView(_ uiView: BannerView, context: Context) {}

	func makeCoordinator() -> BannerCoordinator {
		return BannerCoordinator(self)
	}

	class BannerCoordinator: NSObject, BannerViewDelegate {

		let parent: GoogleBannerViewContainer

		init(_ parent: GoogleBannerViewContainer) {
			self.parent = parent
		}

		// MARK: - GADBannerViewDelegate methods

		func bannerViewDidReceiveAd(_ bannerView: BannerView) {
			print("DID RECEIVE AD.")
		}

		func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
			print("FAILED TO RECEIVE AD: \(error.localizedDescription)")
		}
	}
}
