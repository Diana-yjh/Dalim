//
//  WeeklyRunningView.swift
//  Dalim
//
//  Created by Yejin Hong on 2/25/26.
//

import SwiftUI

struct WeeklyRunningView: View {
    let weeklyDistance: Double
    let weeklyGoalKm: Double
    let todayIndex: Int
    let recordExistsFlags: [Bool]
    var dailyDistances: [Double] = Array(repeating: 0, count: 7)
    var onGoalChange: ((Double) -> Void)?

    @State private var showGoalEditor = false

    var body: some View {
        VStack(spacing: 20) {
            weekGoalSection

            WeeklyBarChartView(
                dailyDistances: dailyDistances,
                todayIndex: todayIndex
            )
        }
        .dianaCard()
        .frame(maxWidth: .infinity, alignment: .leading)
        .sheet(isPresented: $showGoalEditor) {
            GoalEditSheet(currentGoalKm: weeklyGoalKm) { newGoal in
                onGoalChange?(newGoal)
            }
            .presentationDetents([.height(400)])
            .presentationDragIndicator(.visible)
        }
    }

    // MARK: - 주간 목표

    private var weekGoalSection: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 8) {
                Text("WEEKLY GOAL")
                    .font(DianaTheme.captionEngFont())
                    .foregroundStyle(DianaTheme.textSecondary)
                    .tracking(DianaTheme.uppercaseTracking)

                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(String(format: "%.1f", weeklyDistance))
                        .font(DianaTheme.statFont())
                        .foregroundStyle(DianaTheme.neonLime)

                    Text("/ \(String(format: "%.0f", weeklyGoalKm))km")
                        .font(DianaTheme.captionEngFont())
                        .foregroundStyle(DianaTheme.textSecondary)
                        .onTapGesture {
                            showGoalEditor = true
                        }
                }
            }

            Spacer()
            
            CircularChartView(maxValue: weeklyGoalKm, nowValue: weeklyDistance, unit: "%", size: 70)
                .onTapGesture {
                    showGoalEditor = true
                }
        }
    }
}

#Preview {
    WeeklyRunningView(
        weeklyDistance: 29.0,
        weeklyGoalKm: 40.0,
        todayIndex: 2,
        recordExistsFlags: [true, true, false, false, false, false, false],
        dailyDistances: [5.2, 3.1, 7.0, 0, 4.5, 0, 2.0]
    )
}
