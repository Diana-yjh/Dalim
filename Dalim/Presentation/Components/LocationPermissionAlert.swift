//
//  LocationPermissionAlert.swift
//  Dalim
//
//  Created by Yejin Hong on 3/11/26.
//

import SwiftUI

struct LocationPermissionView: View {
    var onOpenSettings: () -> Void
    var onDismiss: () -> Void

    @State private var animate = false

    var body: some View {
        ZStack {
            DianaTheme.backgroundPrimary
                .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                iconSection

                textSection

                featureList

                Spacer()

                buttonSection
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }

    // MARK: - 아이콘
    private var iconSection: some View {
        ZStack {
            Circle()
                .fill(DianaTheme.neonLime.opacity(0.08))
                .frame(width: 140, height: 140)
                .scaleEffect(animate ? 1.1 : 1.0)
                .animation(
                    .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                    value: animate
                )

            Circle()
                .fill(DianaTheme.neonLime.opacity(0.15))
                .frame(width: 100, height: 100)

            Image(systemName: "location.slash.fill")
                .font(.system(size: 40))
                .foregroundStyle(DianaTheme.neonLime)
        }
        .onAppear { animate = true }
    }

    // MARK: - 타이틀
    private var textSection: some View {
        VStack(spacing: 12) {
            Text("위치 권한이 꺼져 있어요")
                .font(DianaTheme.titleFont(24))
                .foregroundStyle(DianaTheme.textPrimary)
                .multilineTextAlignment(.center)

            Text("러닝 기능을 사용하려면\n설정에서 위치 권한을 허용해 주세요")
                .font(DianaTheme.bodyFont(15))
                .foregroundStyle(DianaTheme.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
    }

    // MARK: - 기능 리스트
    private var featureList: some View {
        VStack(spacing: 0) {
            featureRow(
                icon: "map.fill",
                color: DianaTheme.neonBlue,
                title: "실시간 경로 추적",
                description: "러닝 중 이동 경로를 지도에 표시합니다"
            )

            Divider()
                .overlay(DianaTheme.cardBorder)

            featureRow(
                icon: "ruler.fill",
                color: DianaTheme.neonLime,
                title: "정확한 거리 측정",
                description: "GPS 기반으로 이동 거리를 정밀하게 측정합니다"
            )

            Divider()
                .overlay(DianaTheme.cardBorder)

            featureRow(
                icon: "cloud.sun.fill",
                color: DianaTheme.neonOrange,
                title: "현재 위치 날씨",
                description: "러닝 전 날씨 정보를 확인할 수 있습니다"
            )
        }
        .dianaCard()
    }

    private func featureRow(
        icon: String,
        color: Color,
        title: String,
        description: String
    ) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(color)
                .frame(width: 36, height: 36)
                .background(color.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(DianaTheme.bodyFont(15))
                    .foregroundStyle(DianaTheme.textPrimary)

                Text(description)
                    .font(DianaTheme.captionKorFont(12))
                    .foregroundStyle(DianaTheme.textTertiary)
            }

            Spacer()
        }
        .padding(.vertical, 14)
    }

    // MARK: - 버튼
    private var buttonSection: some View {
        VStack(spacing: 12) {
            Button(action: onOpenSettings) {
                HStack(spacing: 8) {
                    Image(systemName: "gearshape.fill")
                    Text("설정으로 이동하기")
                        .font(DianaTheme.headlineFont(16))
                }
                .foregroundStyle(DianaTheme.backgroundPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(DianaTheme.neonLime)
                .clipShape(RoundedRectangle(cornerRadius: DianaTheme.cardCornerRadius))
            }

            Button(action: onDismiss) {
                Text("나중에 하기")
                    .font(DianaTheme.bodyFont(14))
                    .foregroundStyle(DianaTheme.textTertiary)
            }
        }
    }
}

#Preview {
    LocationPermissionView(
        onOpenSettings: {},
        onDismiss: {}
    )
}
