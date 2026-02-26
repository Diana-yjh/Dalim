//
//  StatCardView.swift
//  Dalim
//
//  Created by Yejin Hong on 2/26/26.
//

import SwiftUI

struct StatCardView: View {
    let caption: String
    let value: String
    let alert: String
    let alertColor: Color
    var borderColor: Color = DianaTheme.cardBorder

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(caption)
                .font(DianaTheme.captionEngFont())
                .foregroundStyle(DianaTheme.textSecondary)
                .tracking(DianaTheme.uppercaseTracking)

            Text(value)
                .font(DianaTheme.statFont(24))
                .foregroundStyle(DianaTheme.textPrimary)

            Text(alert)
                .font(DianaTheme.captionKorFont())
                .foregroundStyle(alertColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .dianaCard(borderColor)
    }
}

#Preview {
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
    .padding()
    .background(DianaTheme.backgroundPrimary)
}
