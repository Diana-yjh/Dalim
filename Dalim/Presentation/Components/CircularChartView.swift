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
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    DianaTheme.backgroundSecondary,
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
            
            Circle()
                .trim(from: 0, to: 0.8)
                .stroke(
                    DianaTheme.limeGradient,
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: DianaTheme.neonLime.opacity(0.5), radius: 2)
            
            Text("73%")
                .font(DianaTheme.statFont(18))
                .foregroundStyle(DianaTheme.neonLime)
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    CircularChartView(maxValue: 10.0, nowValue: 2.5, unit: "%", size: 50)
}
