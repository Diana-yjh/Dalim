//
//  WeeklyRunningView.swift
//  Dalim
//
//  Created by Yejin Hong on 2/25/26.
//

import SwiftUI

struct WeeklyRunningView: View {
//    let headerCaption: String
//    var weeklyDistance: Double
//    var weeklyGoalDistance: Double
    
    var body: some View {
        VStack(spacing: 20) {
            weakGoalSection
            
            weekCalendarSection
        }
        .dianaCard(DianaTheme.backgroundPrimary)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var weakGoalSection: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 8) {
                Text("WEAKLY GOAL")
                    .font(DianaTheme.captionEngFont())
                    .foregroundStyle(DianaTheme.textSecondary)
                
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text("29.0")
                        .font(DianaTheme.statFont())
                        .foregroundStyle(DianaTheme.neonLime)
                    
                    Text("/ 40km")
                        .font(DianaTheme.captionEngFont())
                        .foregroundStyle(DianaTheme.textSecondary)
                }
            }
            
            Spacer()
            
            CircularChartView(maxValue: 10.0, nowValue: 2.5, unit: "%", size: 70)
        }
    }
    
    private var weekCalendarSection: some View {
        HStack(spacing: 8) {
            weekCalendarCell(dayOfTheWeek: "월")
            weekCalendarCell(dayOfTheWeek: "화")
            weekCalendarCell(dayOfTheWeek: "수")
            weekCalendarCell(dayOfTheWeek: "목")
            weekCalendarCell(dayOfTheWeek: "금")
            weekCalendarCell(dayOfTheWeek: "토")
            weekCalendarCell(dayOfTheWeek: "일")
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
    WeeklyRunningView()
}

