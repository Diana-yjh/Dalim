//
//  DashboardView.swift
//  Dalim
//
//  Created by Yejin Hong on 2/24/26.
//

import SwiftUI

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = DashboardViewModel()
    @Binding var selectedTab: Int

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ProfileHeaderView(
                        userName: viewModel.userName,
                        profileImageData: viewModel.profileImageData
                    )

                    StatsRowView(
                        steps: viewModel.todaySteps,
                        kcal: viewModel.todayKcal,
                        bpm: viewModel.currentBPM
                    )

                    WeeklyRunningView(
                        weeklyDistance: viewModel.weeklyDistance,
                        weeklyGoalKm: viewModel.weeklyGoalKm,
                        todayIndex: viewModel.todayIndex,
                        recordExistsFlags: viewModel.recordExistsFlags,
                        dailyDistances: viewModel.dailyDistances
                    )

                    StartRunningCardView(
                        headerCaption: "READY TO RUN?",
                        actionTitle: "러닝 시작하기",
                        weatherSummary: viewModel.weatherSummary,
                        selectedTab: $selectedTab
                    )

                    HStack(spacing: 8) {
                        StatCardView(
                            caption: "AVG PACE",
                            value: viewModel.averagePaceString,
                            alert: viewModel.paceChangeText,
                            alertColor: viewModel.alertColor
                        )

                        StatCardView(
                            caption: "TOTAL RUNS",
                            value: "\(viewModel.totalRuns)",
                            alert: viewModel.consecutiveDays > 0
                                ? "\(viewModel.consecutiveDays)일 연속"
                                : "러닝을 시작해보세요",
                            alertColor: viewModel.consecutiveDays > 0
                                ? DianaTheme.neonOrange
                                : DianaTheme.textSecondary
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .background(DianaTheme.backgroundPrimary)
            .navigationTitle("대시보드")
            .toolbarBackground(DianaTheme.backgroundPrimary, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .task {
                await viewModel.loadData(modelContext: modelContext)
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
