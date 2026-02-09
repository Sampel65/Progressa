//
//  L10n.swift
//  task
//
//  Localization helpers. Use String(localized:) for UI strings;
//  keys are defined in Localizable.xcstrings (en, fr, es).
//

import Foundation

enum L10n {

    /// Format string: "Stage %lld of %lld"
    static func stageOfTotal(_ current: Int, total: Int) -> String {
        String(format: String(localized: "Stage %lld of %lld"), Int64(current), Int64(total))
    }

    /// Format string: "%lld of %lld lessons"
    static func lessonsProgress(completed: Int, total: Int) -> String {
        String(format: String(localized: "%lld of %lld lessons"), Int64(completed), Int64(total))
    }

    /// Streak label: "1 day" / "2 days"
    static func streakDays(_ count: Int) -> String {
        if count == 1 {
            return "\(count) \(String(localized: "day"))"
        }
        return "\(count) \(String(localized: "days"))"
    }

    /// Badge count: "1 badge" / "2 badges"
    static func badgeCount(_ count: Int) -> String {
        if count == 1 {
            return "\(count) \(String(localized: "badge"))"
        }
        return "\(count) \(String(localized: "badges"))"
    }
}
