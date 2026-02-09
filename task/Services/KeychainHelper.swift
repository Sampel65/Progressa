//
//  KeychainHelper.swift
//  task
//
//  Created by Samson Oluwapelumi on 08/02/2026.
//

import Foundation
import Security

// ═══════════════════════════════════════════════════════
// MARK: - Keychain Helper
// ═══════════════════════════════════════════════════════

/// A lightweight wrapper around the iOS Keychain for securely
/// storing user credentials locally on the device.
/// 
/// Keychain items are automatically deleted when the app is uninstalled
/// due to the `kSecAttrAccessibleWhenUnlockedThisDeviceOnly` accessibility setting.
enum KeychainHelper {

    private static let serviceName: String = {
        // Use the app's bundle identifier for proper scoping
        // This ensures Keychain items are tied to the app and deleted on uninstall
        if let bundleId = Bundle.main.bundleIdentifier {
            return "\(bundleId).auth"
        }
        return "com.samson.task.auth"
    }()

    // MARK: - Public API

    /// Saves a value to the Keychain for the given key.
    @discardableResult
    static func save(key: String, value: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }

        // Delete any existing item first
        delete(key: key)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            // This accessibility setting ensures Keychain items are automatically
            // deleted when the app is uninstalled from the device
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    /// Retrieves a value from the Keychain for the given key.
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

    /// Deletes a value from the Keychain.
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

    /// Removes all items stored by this app.
    /// This is automatically called when the app is deleted, but can also be called manually.
    static func clearAll() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName
        ]
        SecItemDelete(query as CFDictionary)
    }
}

// ═══════════════════════════════════════════════════════
// MARK: - Keychain Keys
// ═══════════════════════════════════════════════════════

extension KeychainHelper {
    enum Keys {
        static let userEmail = "user_email"
        static let userPassword = "user_password"
        static let userName = "user_name"
        static let isLoggedIn = "is_logged_in"
    }
}
