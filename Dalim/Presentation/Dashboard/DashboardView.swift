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
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    StartRunningCardView(
                        headerCaption: "READY TO RUN?",
                        actionTitle: "러닝 시작하기",
                        weatherSummary: "맑음 · 체감 -2°C · 러닝 적합 🟢"
                    )
                    
                    WeeklyRunningView()
                    
                    HStack(spacing: 8) {
                        StatCardView(
                            caption: "AVG PACE",
                            value: "5'42\"",
                            alert: "▲ 0'12\" 상승",
                            alertColor: DianaTheme.neonLime
                        )

                        StatCardView(
                            caption: "TOTAL RUNS",
                            value: "12",
                            alert: "🔥 5일 연속",
                            alertColor: DianaTheme.neonOrange
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
        }
    }
}

#Preview {
    DashboardView()
}
