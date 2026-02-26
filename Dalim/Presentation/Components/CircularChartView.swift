//
//  CircularChartView.swift
//  Dalim
//
//  Created by Yejin Hong on 2/25/26.
//

import Charts
import SwiftUI

struct CircularChartView: View {
    let maxValue: Double
    let nowValue: Double
    let unit: String
    let size: Double

    private var percentage: Double {
        guard maxValue > 0 else { return 0 }
        return min(nowValue / maxValue, 1.0)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    DianaTheme.backgroundSecondary,
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )

            Circle()
                .trim(from: 0, to: percentage)
                .stroke(
                    DianaTheme.limeGradient,
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: DianaTheme.neonLime.opacity(0.5), radius: 2)

            Text("\(Int(percentage * 100))%")
                .font(DianaTheme.statFont(18))
                .foregroundStyle(DianaTheme.neonLime)
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    CircularChartView(maxValue: 10.0, nowValue: 2.5, unit: "%", size: 50)
}
