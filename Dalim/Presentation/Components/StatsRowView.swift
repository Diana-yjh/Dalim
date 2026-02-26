//
//  StatsRowView.swift
//  Dalim
//
//  Created by Yejin Hong on 2/26/26.
//

import SwiftUI

struct StatsRowView: View {
    let steps: String
    let kcal: String
    let bpm: String

    var body: some View {
        HStack(spacing: 0) {
            statColumn(label: "STEPS", value: steps)
            columnDivider
            statColumn(label: "KCAL", value: kcal)
            columnDivider
            statColumn(label: "BPM", value: bpm)
        }
        .dianaCard()
    }

    // MARK: - 통계 열

    private func statColumn(label: String, value: String) -> some View {
        VStack(spacing: 6) {
            Text(label)
                .font(DianaTheme.captionEngFont(11))
                .foregroundStyle(DianaTheme.textSecondary)
                .tracking(DianaTheme.uppercaseTracking)

            Text(value)
                .font(DianaTheme.statFont(22))
                .foregroundStyle(DianaTheme.textPrimary)
        }
        .frame(maxWidth: .infinity)
    }

    private var columnDivider: some View {
        Rectangle()
            .fill(DianaTheme.cardBorder)
            .frame(width: 0.5, height: 30)
    }
}

#Preview {
    StatsRowView(steps: "8,421", kcal: "342", bpm: "72")
        .padding()
        .background(DianaTheme.backgroundPrimary)
}
