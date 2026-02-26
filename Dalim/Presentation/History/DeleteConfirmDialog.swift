//
//  DeleteConfirmDialog.swift
//  Dalim
//
//  Created by Yejin Hong on 2/26/26.
//

import SwiftUI

struct DeleteConfirmDialog: View {
    var onDelete: () -> Void
    var onCancel: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture { onCancel() }

            VStack(spacing: 20) {
                // MARK: - 아이콘
                ZStack {
                    Circle()
                        .fill(DianaTheme.error.opacity(0.15))
                        .frame(width: 56, height: 56)

                    Image(systemName: "trash.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(DianaTheme.error)
                }

                // MARK: - 텍스트
                VStack(spacing: 8) {
                    Text("기록을 삭제할까요?")
                        .font(DianaTheme.subtitleFont(18))
                        .foregroundStyle(DianaTheme.textPrimary)

                    Text("삭제된 기록은 복구할 수 없습니다.")
                        .font(DianaTheme.captionKorFont(14))
                        .foregroundStyle(DianaTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }

                // MARK: - 버튼
                HStack(spacing: 12) {
                    Button {
                        onCancel()
                    } label: {
                        Text("취소")
                            .frame(maxWidth: .infinity)
                            .font(DianaTheme.headlineFont(16))
                            .foregroundStyle(DianaTheme.textPrimary)
                            .padding(.vertical, 14)
                            .background(
                                Capsule()
                                    .stroke(DianaTheme.textTertiary, lineWidth: 1)
                            )
                    }

                    Button {
                        onDelete()
                    } label: {
                        Text("삭제")
                            .frame(maxWidth: .infinity)
                            .font(DianaTheme.headlineFont(16))
                            .foregroundStyle(.white)
                            .padding(.vertical, 14)
                            .background(DianaTheme.error)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(DianaTheme.backgroundCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(DianaTheme.textTertiary.opacity(0.3), lineWidth: 0.5)
                    )
            )
            .padding(.horizontal, 40)
            .transition(.scale(scale: 0.9).combined(with: .opacity))
        }
        .animation(.easeOut(duration: 0.2), value: true)
    }
}
