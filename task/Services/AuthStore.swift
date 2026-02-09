//
//  AuthStore.swift
//  task
//
//  Created by Samson Oluwapelumi on 05/02/2026.
//


import Foundation

/// User profile data structure containing account information.
struct UserProfile: Codable, Equatable {
    let name: String
    let email: String
    let joinedDate: Date

    /// Extracts the first name from the full name for personalized greetings.
    var firstName: String {
        name.components(separatedBy: " ").first ?? name
    }
}

/// Represents the current authentication state of the app.
enum AuthState: Equatable {
    case unknown
    case onboarding
    case authenticated(UserProfile)
}

/// Authentication-related error types with localized descriptions.
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


/// Manages authentication state and user session lifecycle.
/// Handles sign up, sign in, session restoration, and credential storage in Keychain.
@Observable
final class AuthStore {

    /// Current authentication state, private setter ensures state changes go through controlled methods.
    private(set) var authState: AuthState = .unknown
    
    /// Loading indicator for async authentication operations.
    var isLoading = false
    
    /// Current authentication error, if any.
    var error: AuthError?


    var isAuthenticated: Bool {
        if case .authenticated = authState { return true }
        return false
    }

    var currentUser: UserProfile? {
        if case .authenticated(let profile) = authState { return profile }
        return nil
    }


    init() {
        restoreSession()
    }


    /// Attempts to restore a previous session from Keychain on app launch.
    /// If valid credentials exist, restores the authenticated state; otherwise shows onboarding.
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
            joinedDate: Date()
        )
        authState = .authenticated(profile)
    }


    /// Creates a new user account with validation and stores credentials securely.
    /// Validates: name length (min 2), email format, password strength (min 8 chars), password match.
    /// Checks for existing account to prevent duplicates.
    /// Stores all credentials in Keychain and updates auth state on success.
    ///
    /// - Parameters:
    ///   - name: User's full name
    ///   - email: User's email address
    ///   - password: User's chosen password
    ///   - confirmPassword: Password confirmation for validation
    /// - Returns: `true` if sign up succeeded, `false` if validation failed
    func signUp(name: String, email: String, password: String, confirmPassword: String) async -> Bool {
        error = nil

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

        if let existingEmail = KeychainHelper.read(key: KeychainHelper.Keys.userEmail),
           existingEmail.lowercased() == email.lowercased() {
            error = .accountAlreadyExists
            return false
        }

        isLoading = true

        try? await Task.sleep(for: .milliseconds(1200))

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

        try? await Task.sleep(for: .milliseconds(1000))

        guard let storedEmail = KeychainHelper.read(key: KeychainHelper.Keys.userEmail),
              let storedPassword = KeychainHelper.read(key: KeychainHelper.Keys.userPassword),
              storedEmail.lowercased() == email.lowercased(),
              storedPassword == password else {
            isLoading = false
            error = .invalidCredentials
            return false
        }

        let name = KeychainHelper.read(key: KeychainHelper.Keys.userName) ?? "Learner"

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


    func signOut() {
        KeychainHelper.save(key: KeychainHelper.Keys.isLoggedIn, value: "false")
        authState = .onboarding
        error = nil
    }


    func clearAllData() {
        KeychainHelper.clearAll()
        authState = .onboarding
        error = nil
    }


    /// Validates email format using regex pattern matching.
    /// Pattern requires: local part with alphanumeric and common symbols, @ symbol,
    /// domain name, and TLD with at least 2 characters.
    private func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return email.range(of: pattern, options: .regularExpression) != nil
    }

    func clearError() {
        error = nil
    }
}
