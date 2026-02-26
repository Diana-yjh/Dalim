//
//  MainTabView.swift
//  Dalim
//
//  Created by Yejin Hong on 2/25/26.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("대시보드", systemImage: "house.fill", value: 0) {
                DashboardView(selectedTab: $selectedTab)
            }
            
            Tab("러닝", systemImage: "figure.run", value: 1) {
                RunningSetupView()
            }
            
            Tab("기록", systemImage: "list.star", value: 2) {
                HistoryView()
            }
            
            Tab("마이페이지", systemImage: "person.fill", value: 3) {
                MyPageView()
            }
        }
        .tint(DianaTheme.neonLime)
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.stackedLayoutAppearance.normal.iconColor = .white
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor(DianaTheme.neonLime)
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(DianaTheme.neonLime)]
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}
