//
//  AccountLinkSheet.swift
//  Dalim
//
//  Created by Yejin Hong on 2/26/26.
//

import SwiftUI
import AuthenticationServices

struct AccountLinkSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onResult: (AuthResult) -> Void

    @State private var isLoading = false
    @State private var errorMessage: String?

    private let authService = AuthService()

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                headerSection

                VStack(spacing: 12) {
                    appleSignInButton
                    googleSignInButton
                }
                .padding(.horizontal, 24)

                if let errorMessage {
                    Text(errorMessage)
                        .font(DianaTheme.captionKorFont())
                        .foregroundStyle(DianaTheme.error)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }

                Spacer()
                Spacer()
            }
            .background(DianaTheme.backgroundPrimary)
            .navigationTitle("계정 연동")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(DianaTheme.backgroundPrimary, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("닫기") { dismiss() }
                        .foregroundStyle(DianaTheme.textSecondary)
                }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "person.badge.plus")
                .font(.system(size: 48))
                .foregroundStyle(DianaTheme.neonLime)

            Text("계정을 연동하세요")
                .font(DianaTheme.subtitleFont(20))
                .foregroundStyle(DianaTheme.textPrimary)

            Text("Apple 또는 Google 계정으로 로그인하여\n프로필을 연동할 수 있습니다.")
                .font(DianaTheme.captionKorFont(14))
                .foregroundStyle(DianaTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.bottom, 8)
    }

    // MARK: - Apple Sign In

    private var appleSignInButton: some View {
        Button {
            Task { await performAppleSignIn() }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "apple.logo")
                    .font(.system(size: 18))
                Text("Apple로 로그인")
                    .font(DianaTheme.bodyFont())
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color(hex: "333333"))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(isLoading)
    }

    // MARK: - Google Sign In

    private var googleSignInButton: some View {
        Button {
            Task { await performGoogleSignIn() }
        } label: {
            HStack(spacing: 8) {
                Text("G")
                    .font(.system(size: 18, weight: .bold))
                Text("Google로 로그인")
                    .font(DianaTheme.bodyFont())
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color(hex: "4285F4"))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(isLoading)
    }

    // MARK: - Actions

    @MainActor
    private func performAppleSignIn() async {
        isLoading = true
        errorMessage = nil
        do {
            let result = try await authService.signInWithApple()
            onResult(result)
            dismiss()
        } catch AuthError.cancelled {
            // 사용자가 취소 — 무시
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    @MainActor
    private func performGoogleSignIn() async {
        isLoading = true
        errorMessage = nil
        do {
            let result = try await authService.signInWithGoogle()
            onResult(result)
            dismiss()
        } catch AuthError.cancelled {
            // 사용자가 취소 — 무시
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

#Preview {
    AccountLinkSheet { result in
        print("Linked: \(result.provider) - \(result.name)")
    }
}
