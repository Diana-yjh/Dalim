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

// MARK: - UserDefaults Keys

private enum AuthUserDefaultsKey {
    static let appleUserID = "auth_apple_userID"
    static let appleUserName = "auth_apple_userName"
    static let appleUserEmail = "auth_apple_userEmail"
    static let authProvider = "auth_provider"
}

// MARK: - AuthService

final class AuthService: NSObject, @unchecked Sendable {
    private var appleSignInContinuation: CheckedContinuation<AuthResult, Error>?

    // MARK: - UserDefaults 캐시 조회

    /// 앱 실행 시 저장된 Apple 로그인 정보가 있는지 확인
    static func cachedAuthResult() -> AuthResult? {
        let defaults = UserDefaults.standard
        guard let provider = defaults.string(forKey: AuthUserDefaultsKey.authProvider),
              let userID = defaults.string(forKey: AuthUserDefaultsKey.appleUserID),
              !userID.isEmpty else {
            return nil
        }
        let name = defaults.string(forKey: AuthUserDefaultsKey.appleUserName) ?? "러너"
        return AuthResult(name: name, provider: provider, userID: userID)
    }

    /// UserDefaults에 Apple 로그인 정보 저장 (최초 로그인 시)
    private static func saveToUserDefaults(name: String, userID: String, email: String?, provider: String) {
        let defaults = UserDefaults.standard
        defaults.set(userID, forKey: AuthUserDefaultsKey.appleUserID)
        defaults.set(name, forKey: AuthUserDefaultsKey.appleUserName)
        defaults.set(provider, forKey: AuthUserDefaultsKey.authProvider)
        if let email {
            defaults.set(email, forKey: AuthUserDefaultsKey.appleUserEmail)
        }
    }

    /// 로그아웃 시 저장된 정보 삭제
    static func clearCachedAuth() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: AuthUserDefaultsKey.appleUserID)
        defaults.removeObject(forKey: AuthUserDefaultsKey.appleUserName)
        defaults.removeObject(forKey: AuthUserDefaultsKey.appleUserEmail)
        defaults.removeObject(forKey: AuthUserDefaultsKey.authProvider)
    }

    // MARK: - Apple 로그인

    func signInWithApple2() async throws -> AuthResult {
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

        // 최초 로그인: fullName이 제공되면 UserDefaults에 저장
        // 재로그인: fullName이 빈 문자열이면 UserDefaults에서 캐시된 이름 사용
        let name: String
        if !fullName.isEmpty {
            name = fullName
            AuthService.saveToUserDefaults(
                name: fullName,
                userID: credential.user,
                email: credential.email,
                provider: "apple"
            )
        } else if let cached = AuthService.cachedAuthResult(), cached.userID == credential.user {
            name = cached.name
        } else {
            name = "러너"
            AuthService.saveToUserDefaults(
                name: "러너",
                userID: credential.user,
                email: credential.email,
                provider: "apple"
            )
        }

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
