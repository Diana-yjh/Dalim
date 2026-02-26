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
                    headerView()
                    
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
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
    
    private func headerView() -> some View {
        HStack(spacing: 6) {
            VStack(alignment: .leading, spacing: 8) {
                Text("SUNDAY, FEB 23")
                    .font(DianaTheme.captionEngFont())
                    .foregroundStyle(DianaTheme.textSecondary)
                
                Text("좋은 저녁이에요 👋")
                    .font(DianaTheme.titleFont())
                    .foregroundStyle(DianaTheme.textPrimary)
            }
            
            Spacer()
            
            Button {
                
            } label: {
                Image(systemName: "figure.run")
                    .size(15)
            }
            .buttonStyle(DianaCircleButtonStyle(color: DianaTheme.neonLime, size: 30))
        }
    }
}

#Preview {
    DashboardView()
}
