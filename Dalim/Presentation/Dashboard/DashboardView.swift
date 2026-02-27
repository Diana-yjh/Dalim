//
//  DashboardView.swift
//  Dalim
//
//  Created by Yejin Hong on 2/24/26.
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @State private var viewModel = DashboardViewModel()
    @State private var showLinkSheet = false
    @Binding var selectedTab: Int

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    ProfileHeaderView(
                        userName: viewModel.userName,
                        profileImageData: viewModel.profileImageData,
                        isLinked: viewModel.isLinked,
                        onLinkAccount: { showLinkSheet = true }
                    )

                    WeeklyRunningView(
                        weeklyDistance: viewModel.weeklyDistance,
                        weeklyGoalKm: viewModel.weeklyGoalKm,
                        todayIndex: viewModel.todayIndex,
                        recordExistsFlags: viewModel.recordExistsFlags,
                        dailyDistances: viewModel.dailyDistances,
                        onGoalChange: { km in
                            viewModel.updateWeeklyGoal(km: km, modelContext: modelContext)
                        }
                    )

                    StartRunningCardView(
                        headerCaption: "READY TO RUN?",
                        actionTitle: "러닝 시작하기 🏃",
                        weatherSummary: viewModel.weatherSummary,
                        selectedTab: $selectedTab
                    )

                    HStack(spacing: 8) {
                        StatCardView(
                            caption: "AVG PACE",
                            value: viewModel.averagePaceString,
                            unit: "km",
                            alert: viewModel.paceChangeText,
                            alertColor: viewModel.alertColor
                        )

                        StatCardView(
                            caption: "TOTAL RUNS",
                            value: "\(viewModel.totalRuns)",
                            unit: "일",
                            alert: viewModel.consecutiveDays > 0
                                ? "🔥 \(viewModel.consecutiveDays)일 연속"
                                : "러닝을 시작해보세요",
                            alertColor: viewModel.consecutiveDays > 0
                                ? DianaTheme.neonOrange
                                : DianaTheme.textSecondary
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 24)
            }
            .background(DianaTheme.backgroundPrimary)
            .toolbarBackground(DianaTheme.backgroundPrimary, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .task {
                await viewModel.loadData(modelContext: modelContext)
            }
            .sheet(isPresented: $showLinkSheet) {
                AccountLinkSheet { result in
                    let profile = profiles.first ?? {
                        let p = UserProfile()
                        modelContext.insert(p)
                        return p
                    }()
                    profile.name = result.name
                    profile.isLinked = true
                    profile.authProvider = result.provider
                    profile.authUserID = result.userID
                    viewModel.userName = result.name
                    viewModel.isLinked = true
                }
            }
            .onAppear {
                let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.shadowColor = .clear
                UINavigationBar.appearance().standardAppearance = appearance
            }
        }
    }
}

#Preview {
    DashboardView(selectedTab: .constant(0))
}
