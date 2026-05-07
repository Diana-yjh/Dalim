//
//  MainTabView.swift
//  Dalim
//
//  Created by Yejin Hong on 2/25/26.
//

import SwiftUI

struct MainTabView: View {
    @Environment(DIContainer.self) private var diContainer
    
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("대시보드", systemImage: "house.fill", value: 0) {
                DashboardView(selectedTab: $selectedTab, viewModel: diContainer.makeDashboardViewModel())
            }
            
            Tab("러닝", systemImage: "figure.run", value: 1) {
                RunningSetupView(viewModel: diContainer.makeRunningSetupViewModel())
            }
            
            Tab("기록", systemImage: "list.star", value: 2) {
                HistoryView()
            }
            
            Tab("마이페이지", systemImage: "person.fill", value: 3) {
                MyPageView()
            }
        }
//        .safeAreaInset(edge: .top, spacing: 0) {
//            GoogleAdBannerView()
//                .background(DianaTheme.backgroundPrimary)
//        }
        .tint(DianaTheme.neonLime)
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(DianaTheme.backgroundPrimary)
            appearance.stackedLayoutAppearance.normal.iconColor = .white
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor(DianaTheme.neonLime)
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(DianaTheme.neonLime)]
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}
