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

    var body: some View {
        VStack(spacing: 20) {
            weekGoalSection

            weekCalendarSection
        }
        .dianaCard(DianaTheme.textTertiary)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - 주간 목표

    private var weekGoalSection: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 8) {
                Text("WEEKLY GOAL")
                    .font(DianaTheme.captionEngFont())
                    .foregroundStyle(DianaTheme.textSecondary)

                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(String(format: "%.1f", weeklyDistance))
                        .font(DianaTheme.statFont())
                        .foregroundStyle(DianaTheme.neonLime)

                    Text("/ \(String(format: "%.0f", weeklyGoalKm))km")
                        .font(DianaTheme.captionEngFont())
                        .foregroundStyle(DianaTheme.textSecondary)
                }
            }

            Spacer()

            CircularChartView(maxValue: weeklyGoalKm, nowValue: weeklyDistance, unit: "%", size: 70)
        }
    }

    // MARK: - 주간 캘린더

    private var weekCalendarSection: some View {
        let days = ["월", "화", "수", "목", "금", "토", "일"]
        return HStack(spacing: 8) {
            ForEach(0..<7, id: \.self) { index in
                weekCalendarCell(
                    isToday: index == todayIndex,
                    isRecordExist: recordExistsFlags[index],
                    dayOfTheWeek: days[index]
                )
            }
        }
    }
}

struct weekCalendarCell: View {
    var isToday: Bool = false
    var isRecordExist: Bool = false
    let dayOfTheWeek: String

    private var glowColor: Color? {
        if isToday { return DianaTheme.neonBlue }
        if isRecordExist { return DianaTheme.neonLime }
        return nil
    }

    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 40, height: 45)
                    .foregroundStyle(glowColor?.opacity(0.15) ?? DianaTheme.backgroundSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(glowColor ?? .clear, lineWidth: 1)
                    )
                    .shadow(color: glowColor?.opacity(0.6) ?? .clear, radius: 6)

                Circle()
                    .frame(width: 8, height: 8)
                    .foregroundStyle(glowColor ?? DianaTheme.textSecondary)
            }

            Text(dayOfTheWeek)
                .font(DianaTheme.bodyFont(12))
                .foregroundStyle(isToday ? DianaTheme.neonBlue : DianaTheme.textPrimary)
        }
    }
}

#Preview {
    WeeklyRunningView(
        weeklyDistance: 29.0,
        weeklyGoalKm: 40.0,
        todayIndex: 2,
        recordExistsFlags: [true, true, false, false, false, false, false]
    )
}
