//
//  AuthStore.swift
//  task
//
//  Created by Samson Oluwapelumi on 08/02/2026.
//

import Foundation

// ═══════════════════════════════════════════════════════
// MARK: - User Profile
// ═══════════════════════════════════════════════════════

struct UserProfile: Codable, Equatable {
    let name: String
    let email: String
    let joinedDate: Date

    var firstName: String {
        name.components(separatedBy: " ").first ?? name
    }
}

// ═══════════════════════════════════════════════════════
// MARK: - Auth State
// ═══════════════════════════════════════════════════════

enum AuthState: Equatable {
    case unknown
    case onboarding
    case authenticated(UserProfile)
}

// ═══════════════════════════════════════════════════════
// MARK: - Auth Error
// ═══════════════════════════════════════════════════════

enum AuthError: LocalizedError, Equatable {
    case invalidEmail
    case weakPassword
    case passwordMismatch
    case nameTooShort
    case accountAlreadyExists
    case invalidCredentials
    case unknownError

    var errorDescription: String? {
        switch self {
        case .invalidEmail: return String(localized: "Please enter a valid email address.")
        case .weakPassword: return String(localized: "Password must be at least 8 characters.")
        case .passwordMismatch: return String(localized: "Passwords do not match.")
        case .nameTooShort: return String(localized: "Name must be at least 2 characters.")
        case .accountAlreadyExists: return String(localized: "An account with this email already exists.")
        case .invalidCredentials: return String(localized: "Invalid email or password.")
        case .unknownError: return String(localized: "Something went wrong. Please try again.")
        }
    }
}

// ═══════════════════════════════════════════════════════
// MARK: - Auth Store
// ═══════════════════════════════════════════════════════

/// Central observable store managing user authentication state.
/// Credentials are persisted securely in the iOS Keychain.
@Observable
final class AuthStore {

    // MARK: - State

    private(set) var authState: AuthState = .unknown
    var isLoading = false
    var error: AuthError?

    // MARK: - Computed

    var isAuthenticated: Bool {
        if case .authenticated = authState { return true }
        return false
    }

    var currentUser: UserProfile? {
        if case .authenticated(let profile) = authState { return profile }
        return nil
    }

    // MARK: - Init

    init() {
        restoreSession()
    }

    // MARK: - Session Restoration

    /// Checks Keychain for existing credentials on app launch.
    private func restoreSession() {
        guard let isLoggedIn = KeychainHelper.read(key: KeychainHelper.Keys.isLoggedIn),
              isLoggedIn == "true",
              let name = KeychainHelper.read(key: KeychainHelper.Keys.userName),
              let email = KeychainHelper.read(key: KeychainHelper.Keys.userEmail) else {
            authState = .onboarding
            return
        }

        let profile = UserProfile(
            name: name,
            email: email,
            joinedDate: Date() // We don't persist this; could be extended
        )
        authState = .authenticated(profile)
    }

    // MARK: - Sign Up

    /// Creates a new account and persists credentials to Keychain.
    func signUp(name: String, email: String, password: String, confirmPassword: String) async -> Bool {
        error = nil

        // Validation
        guard name.trimmingCharacters(in: .whitespaces).count >= 2 else {
            error = .nameTooShort
            return false
        }
        guard isValidEmail(email) else {
            error = .invalidEmail
            return false
        }
        guard password.count >= 8 else {
            error = .weakPassword
            return false
        }
        guard password == confirmPassword else {
            error = .passwordMismatch
            return false
        }

        // Check if account already exists
        if let existingEmail = KeychainHelper.read(key: KeychainHelper.Keys.userEmail),
           existingEmail.lowercased() == email.lowercased() {
            error = .accountAlreadyExists
            return false
        }

        isLoading = true

        // Simulate network delay for realistic UX
        try? await Task.sleep(for: .milliseconds(1200))

        // Persist credentials
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        KeychainHelper.save(key: KeychainHelper.Keys.userName, value: trimmedName)
        KeychainHelper.save(key: KeychainHelper.Keys.userEmail, value: email.lowercased())
        KeychainHelper.save(key: KeychainHelper.Keys.userPassword, value: password)
        KeychainHelper.save(key: KeychainHelper.Keys.isLoggedIn, value: "true")

        let profile = UserProfile(
            name: trimmedName,
            email: email.lowercased(),
            joinedDate: Date()
        )

        isLoading = false
        authState = .authenticated(profile)
        return true
    }

    // MARK: - Sign In

    /// Authenticates against locally stored credentials.
    func signIn(email: String, password: String) async -> Bool {
        error = nil

        guard isValidEmail(email) else {
            error = .invalidEmail
            return false
        }
        guard !password.isEmpty else {
            error = .weakPassword
            return false
        }

        isLoading = true

        // Simulate network delay
        try? await Task.sleep(for: .milliseconds(1000))

        // Verify credentials
        guard let storedEmail = KeychainHelper.read(key: KeychainHelper.Keys.userEmail),
              let storedPassword = KeychainHelper.read(key: KeychainHelper.Keys.userPassword),
              storedEmail.lowercased() == email.lowercased(),
              storedPassword == password else {
            isLoading = false
            error = .invalidCredentials
            return false
        }

        let name = KeychainHelper.read(key: KeychainHelper.Keys.userName) ?? "Learner"

        // Update session
        KeychainHelper.save(key: KeychainHelper.Keys.isLoggedIn, value: "true")

        let profile = UserProfile(
            name: name,
            email: storedEmail,
            joinedDate: Date()
        )

        isLoading = false
        authState = .authenticated(profile)
        return true
    }

    // MARK: - Sign Out

    func signOut() {
        KeychainHelper.save(key: KeychainHelper.Keys.isLoggedIn, value: "false")
        authState = .onboarding
        error = nil
    }

    // MARK: - Helpers

    private func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return email.range(of: pattern, options: .regularExpression) != nil
    }

    func clearError() {
        error = nil
    }
}
