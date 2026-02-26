//
//  DianaTheme.swift
//  Dalim
//
//  Created by Yejin Hong on 2/24/26.
//

import SwiftUI

enum DianaTheme {
    // MARK: - 메인 컬러
    static let neonLime = Color(hex: "CCFF00")
    static let neonBlue = Color(hex: "08F0FF")
    static let neonPink = Color(hex: "FE2E78")
    static let neonOrange = Color(hex: "FF8800")

    // MARK: - 배경
    static let backgroundPrimary = Color(hex: "0A0A0A")
    static let backgroundSecondary = Color(hex: "1E1E1E")
    static let backgroundCard = Color(hex: "161616")

    // MARK: - 텍스트
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: "A0A0A0")
    static let textTertiary = Color(hex: "6B6B6B")
    
    // MARK: - 상태
    static let success = Color(hex: "34C759")
    static let warning = Color(hex: "FF9F0A")
    static let error = Color(hex: "FF453A")
    
    // MARK: - 그라디언트
    static let neonLime2 = Color(hex: "E5FF66")
    
    static let limeGradient = LinearGradient(colors: [neonLime, neonLime2], startPoint: .leading, endPoint: .trailing)
    static let pinkGradient = LinearGradient(colors: [neonPink, neonOrange], startPoint: .leading, endPoint: .trailing)
    
    // MARK: - 폰트
    static func titleFont(_ size: CGFloat = 28) -> Font {
        .custom("Pretendard-Bold", size: size)
    }

    static func subtitleFont(_ size: CGFloat = 22) -> Font {
        .custom("Pretendard-SemiBold", size: size)
    }
    
    static func headlineFont(_ size: CGFloat = 20) -> Font {
        .custom("Outfit-SemiBold", size: size)
    }

    static func bodyFont(_ size: CGFloat = 16) -> Font {
        .custom("Pretendard-Regular", size: size)
    }

    static func captionKorFont(_ size: CGFloat = 13) -> Font {
        .custom("Pretendard-Light", size: size)
    }
    
    static func captionEngFont(_ size: CGFloat = 13) -> Font {
        .custom("Outfit-Light", size: size)
    }

    static func statFont(_ size: CGFloat = 40) -> Font {
        .custom("SpaceMono-Bold", size: size)
    }
    
    // MARK: - 카드 스타일
    static let cardCornerRadius: CGFloat = 16
    static let cardPadding: CGFloat = 20
    static let cardBorder = Color(hex: "252525")
    static let barInactive = Color(hex: "2A2A2A")

    // MARK: - 타이포그래피
    static let uppercaseTracking: CGFloat = 2.0
}

// MARK: - 카드 디자인 템플릿
struct DianaCardModifier: ViewModifier {
    var borderColor: Color = DianaTheme.cardBorder

    func body(content: Content) -> some View {
        content
            .padding(DianaTheme.cardPadding)
            .background(
                RoundedRectangle(cornerRadius: DianaTheme.cardCornerRadius)
                    .fill(DianaTheme.backgroundCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: DianaTheme.cardCornerRadius)
                            .stroke(borderColor, lineWidth: 0.5)
                    )
            )
    }
}

extension View {
    func dianaCard(_ color: Color = DianaTheme.cardBorder) -> some View {
        modifier(DianaCardModifier(borderColor: color))
    }
}
