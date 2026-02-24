//
//  DianaButtonStyle.swift
//  Dalim
//
//  Created by Yejin Hong on 2/24/26.
//

import SwiftUI

// MARK: - 메인 버튼
struct DianaPrimaryButtonStyle: ButtonStyle {
    var isEnabled: Bool = true
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DianaTheme.headlineFont(18))
            .foregroundStyle(DianaTheme.backgroundPrimary)
            .padding(.horizontal, 32)
            .padding(.vertical, 14)
            .background(
                isEnabled ? DianaTheme.neonLime : DianaTheme.textTertiary
            )
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - 보조 버튼(아웃라인)
struct DianaSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DianaTheme.headlineFont(16))
            .foregroundStyle(DianaTheme.neonLime)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .stroke(DianaTheme.neonLime, lineWidth: 1.5)
            )
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - 원형 버튼(러닝 시작/정지)
struct DianaCircleButtonStyle: ButtonStyle {
    var color: Color = DianaTheme.neonLime
    var size: CGFloat = 80

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DianaTheme.headlineFont(20))
            .foregroundStyle(DianaTheme.backgroundPrimary)
            .frame(width: size, height: size)
            .background(color)
            .clipShape(Circle())
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
