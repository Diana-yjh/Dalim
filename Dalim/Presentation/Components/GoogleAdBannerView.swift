//
//  GoogleAdBannerView.swift
//  Dalim
//
//  Created by Yejin Hong on 4/22/26.
//

import SwiftUI
import GoogleMobileAds

struct GoogleAdBannerView: View {
    @State private var width: CGFloat = UIScreen.main.bounds.width - 50
    
    var body: some View {
        let adSize = currentOrientationInlineAdaptiveBanner(width: width)
        
        BannerViewContainer(adSize: adSize)
            .frame(width: adSize.size.width, height: 50)
            .frame(maxWidth: .infinity)
            .onGeometryChange(for: CGFloat.self) { proxy in
                proxy.size.width
            } action: { newWidth in
                width = newWidth
            }
    }
}

struct BannerViewContainer: UIViewRepresentable {
    let adSize: AdSize

    func makeCoordinator() -> Coordinator { Coordinator() }
    
    func makeUIView(context: Context) -> some BannerView {
        let banner = BannerView(adSize: adSize)
        
        #if DEBUG
        banner.adUnitID = "ca-app-pub-3940256099942544/2435281174"
        #else
        banner.adUnitID = "ca-app-pub-9681631255122904/1509546497"
        #endif
        
        banner.rootViewController = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow?.rootViewController }
            .first
        banner.delegate = context.coordinator
        banner.load(Request())
        return banner
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}

    class Coordinator: NSObject, BannerViewDelegate {
        func bannerViewDidReceiveAd(_ bannerView: BannerView) {
            print("✅ Ad received")
        }
        func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
            print("❌ Ad failed: \(error.localizedDescription)")
        }
    }
}
