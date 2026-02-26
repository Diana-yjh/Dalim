//
//  AuthService.swift
//  Dalim
//
//  Created by Yejin Hong on 2/26/26.
//

import Foundation
import AuthenticationServices

// MARK: - AuthResult

struct AuthResult {
    let name: String
    let provider: String      // "apple" | "google"
    let userID: String
}

// MARK: - AuthService

final class AuthService: NSObject, @unchecked Sendable {
    private var appleSignInContinuation: CheckedContinuation<AuthResult, Error>?

    // MARK: - Apple 로그인

    @MainActor
    func signInWithApple() async throws -> AuthResult {
        try await withCheckedThrowingContinuation { continuation in
            self.appleSignInContinuation = continuation

            let provider = ASAuthorizationAppleIDProvider()
            let request = provider.createRequest()
            request.requestedScopes = [.fullName, .email]

            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }
    }

    // MARK: - Google 로그인

    @MainActor
    func signInWithGoogle() async throws -> AuthResult {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else {
            throw AuthError.noRootViewController
        }

        return try await withCheckedThrowingContinuation { continuation in
            // Google Sign-In은 SPM 패키지 추가 후 활성화
            // GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { result, error in ... }
            continuation.resume(throwing: AuthError.googleSignInNotConfigured)
        }
    }
}

// MARK: - AuthError

enum AuthError: LocalizedError {
    case cancelled
    case noCredential
    case noRootViewController
    case googleSignInNotConfigured

    var errorDescription: String? {
        switch self {
        case .cancelled: return "로그인이 취소되었습니다."
        case .noCredential: return "인증 정보를 가져올 수 없습니다."
        case .noRootViewController: return "화면을 표시할 수 없습니다."
        case .googleSignInNotConfigured: return "Google 로그인이 아직 설정되지 않았습니다."
        }
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AuthService: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            appleSignInContinuation?.resume(throwing: AuthError.noCredential)
            appleSignInContinuation = nil
            return
        }

        let fullName = [credential.fullName?.givenName, credential.fullName?.familyName]
            .compactMap { $0 }
            .joined(separator: " ")
        let name = fullName.isEmpty ? "러너" : fullName

        let result = AuthResult(
            name: name,
            provider: "apple",
            userID: credential.user
        )

        appleSignInContinuation?.resume(returning: result)
        appleSignInContinuation = nil
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        if let authError = error as? ASAuthorizationError, authError.code == .canceled {
            appleSignInContinuation?.resume(throwing: AuthError.cancelled)
        } else {
            appleSignInContinuation?.resume(throwing: error)
        }
        appleSignInContinuation = nil
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AuthService: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return ASPresentationAnchor()
        }
        return window
    }
}
