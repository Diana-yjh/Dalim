//
//  StartRunningCardView.swift
//  Dalim
//
//  Created by Yejin Hong on 2/24/26.
//

import SwiftUI

struct StartRunningCardView: View {
    let headerCaption: String
    let actionTitle: String
    let weatherSummary: String
    
    var body: some View {
        HStack(spacing: 6) {
            VStack(alignment: .leading, spacing: 8) {
                Text(headerCaption)
                    .font(DianaTheme.captionEngFont())
                    .foregroundStyle(DianaTheme.textSecondary)
                
                Text(actionTitle)
                    .font(DianaTheme.subtitleFont())
                    .foregroundStyle(DianaTheme.textPrimary)
                
                Text(weatherSummary)
                    .font(DianaTheme.captionKorFont())
                    .foregroundStyle(DianaTheme.textSecondary)
            }
            
            Spacer()
            
            Button {
                
            } label: {
                Image(systemName: "play.fill")
                    .size(15)
            }
            .buttonStyle(DianaCircleButtonStyle(color: DianaTheme.neonLime, size: 50))
            .shadow(
                color: DianaTheme.neonLime.opacity(0.5),
                radius: 5
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .dianaCard(DianaTheme.textTertiary)
    }
}

#Preview {
    StartRunningCardView(headerCaption: "READY TO RUN?", actionTitle: "러닝 시작하기", weatherSummary: "맑음 · 체감 -2°C · 러닝 적합 🟢")
}
