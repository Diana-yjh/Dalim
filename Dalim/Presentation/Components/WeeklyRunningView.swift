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
    @State private var goalInput = ""

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
        .alert("주간 목표 설정", isPresented: $showGoalEditor) {
            TextField("목표 거리 (km)", text: $goalInput)
                .keyboardType(.decimalPad)
            Button("저장") {
                if let km = Double(goalInput), km > 0 {
                    onGoalChange?(km)
                }
            }
            Button("취소", role: .cancel) {}
        } message: {
            Text("주간 목표 거리를 km 단위로 입력하세요")
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
                }

                Button {
                    goalInput = String(format: "%.0f", weeklyGoalKm)
                    showGoalEditor = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "pencil")
                        Text("목표 설정")
                    }
                    .font(DianaTheme.captionEngFont())
                    .foregroundStyle(DianaTheme.neonLime)
                }
            }

            Spacer()

            if isGoalSet {
                CircularChartView(maxValue: weeklyGoalKm, nowValue: weeklyDistance, unit: "%", size: 70)
            }
        }
    }
    
    private var isGoalSet: Bool {
        if weeklyGoalKm > 0.0 { return true }
        return false
    }
    
    @ViewBuilder
    private var goalStatusSection: some View {
        if isGoalSet {
            CircularChartView(maxValue: weeklyGoalKm, nowValue: weeklyDistance, unit: "%", size: 70)
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
