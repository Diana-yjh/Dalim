//
//  DianaTheme.swift
//  Dalim
//
//  Created by Yejin Hong on 2/24/26.
//

import SwiftUI

enum DianaTheme {
    // MARK: - 메인 컬러
    static let neonLime = Color(hex: "39FF14")
    static let neonBlue = Color(hex: "08F0FF")
    static let neonPink = Color(hex: "FE2E78")
    static let neonOrange = Color(hex: "FF8800")
    
    // MARK: - 배경
    static let backgroundPrimary = Color(hex: "121212")
    static let backgroundSecondary = Color(hex: "1C1C1E")
    static let backgroundCard = Color(hex: "2C2C2E")
    
    // MARK: - 텍스트
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: "A0A0A0")
    static let textTertiary = Color(hex: "6B6B6B")
    
    // MARK: - 상태
    static let success = Color(hex: "34C759")
    static let warning = Color(hex: "FF9F0A")
    static let error = Color(hex: "FF453A")
    
    // MARK: - 그라디언트
    static let limeGradient = LinearGradient(colors: [neonLime, neonBlue], startPoint: .leading, endPoint: .trailing)
    static let pinktGradient = LinearGradient(colors: [neonPink, neonOrange], startPoint: .leading, endPoint: .trailing)
    
    // MARK: - 폰트
    static func titleFont(_ size: CGFloat = 28) -> Font {
        .custom("Outfit-Bold", size: size)
    }

    static func headlineFont(_ size: CGFloat = 20) -> Font {
        .custom("Outfit-SemiBold", size: size)
    }

    static func bodyFont(_ size: CGFloat = 16) -> Font {
        .custom("Pretendard-Regular", size: size)
    }

    static func captionFont(_ size: CGFloat = 13) -> Font {
        .custom("Pretendard-Light", size: size)
    }

    static func statFont(_ size: CGFloat = 40) -> Font {
        .custom("SpaceMono-Bold", size: size)
    }
    
    // MARK: - 카드 스타일
    static let cardCornerRadius: CGFloat = 16
    static let cardPadding: CGFloat = 16
}

// MARK: - 카드 디자인 템플릿
struct DianaCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(DianaTheme.cardPadding)
            .background(DianaTheme.backgroundCard)
            .clipShape(RoundedRectangle(cornerRadius: DianaTheme.cardCornerRadius))
    }
}

extension View {
    func dianaCard() -> some View {
        modifier(DianaCardModifier())
    }
}
