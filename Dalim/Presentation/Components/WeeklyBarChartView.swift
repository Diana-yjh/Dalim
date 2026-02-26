//
//  WeeklyBarChartView.swift
//  Dalim
//
//  Created by Yejin Hong on 2/26/26.
//

import SwiftUI

struct WeeklyBarChartView: View {
    let dailyDistances: [Double]
    let todayIndex: Int

    private let dayLabels = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
    private let maxBarHeight: CGFloat = 80

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(0..<7, id: \.self) { index in
                barColumn(index: index)
            }
        }
    }

    // MARK: - 바 열

    private func barColumn(index: Int) -> some View {
        let distance = index < dailyDistances.count ? dailyDistances[index] : 0
        let maxDistance = dailyDistances.max() ?? 1
        let ratio = maxDistance > 0 ? distance / maxDistance : 0
        let barHeight = max(ratio * maxBarHeight, 4)
        let isToday = index == todayIndex

        return VStack(spacing: 6) {
            if distance > 0 {
                Text(String(format: "%.1f", distance))
                    .font(DianaTheme.captionEngFont(8))
                    .foregroundStyle(isToday ? DianaTheme.neonLime : DianaTheme.textTertiary)
            }

            RoundedRectangle(cornerRadius: 4)
                .fill(isToday ? DianaTheme.neonLime : DianaTheme.barInactive)
                .frame(width: nil, height: barHeight)
                .frame(maxWidth: .infinity)

            Text(dayLabels[index])
                .font(DianaTheme.captionEngFont(9))
                .foregroundStyle(isToday ? DianaTheme.neonLime : DianaTheme.textSecondary)
                .tracking(DianaTheme.uppercaseTracking)
        }
    }
}

#Preview {
    WeeklyBarChartView(
        dailyDistances: [5.2, 3.1, 7.0, 0, 4.5, 0, 2.0],
        todayIndex: 2
    )
    .padding()
    .background(DianaTheme.backgroundPrimary)
}
