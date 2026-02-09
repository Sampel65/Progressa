//
//  KeychainHelper.swift
//  task
//
//  Created by Samson Oluwapelumi on 05/02/2026.
//


import Foundation
import Security

/// Secure storage wrapper for iOS Keychain operations.
/// Stores authentication credentials with device-only access, ensuring automatic deletion on app uninstall.
enum KeychainHelper {

    /// Service name scoped to the app's bundle identifier for proper Keychain isolation.
    /// Falls back to a default value if bundle ID is unavailable (shouldn't happen in production).
    private static let serviceName: String = {
        if let bundleId = Bundle.main.bundleIdentifier {
            return "\(bundleId).auth"
        }
        return "com.samson.task.auth"
    }()


    /// Saves a string value to Keychain with the specified key.
    /// Uses `kSecAttrAccessibleWhenUnlockedThisDeviceOnly` to ensure credentials are:
    /// - Only accessible when device is unlocked
    /// - Bound to this device (no iCloud sync)
    /// - Automatically deleted when app is uninstalled
    ///
    /// - Parameters:
    ///   - key: The account key for this item
    ///   - value: The string value to store securely
    /// - Returns: `true` if save succeeded, `false` otherwise
    @discardableResult
    static func save(key: String, value: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }

        delete(key: key)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    static func read(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }

        return string
    }

    @discardableResult
    static func delete(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }

    static func clearAll() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName
        ]
        SecItemDelete(query as CFDictionary)
    }
}


extension KeychainHelper {
    enum Keys {
        static let userEmail = "user_email"
        static let userPassword = "user_password"
        static let userName = "user_name"
        static let isLoggedIn = "is_logged_in"
    }
}
