//
//  L10n.swift
//  task
//
//  Created by Samson Oluwapelumi on 08/02/2026.
//


import Foundation

enum L10n {

    static func stageOfTotal(_ current: Int, total: Int) -> String {
        String(format: String(localized: "Stage %lld of %lld"), Int64(current), Int64(total))
    }

    static func lessonsProgress(completed: Int, total: Int) -> String {
        String(format: String(localized: "%lld of %lld lessons"), Int64(completed), Int64(total))
    }

    static func streakDays(_ count: Int) -> String {
        if count == 1 {
            return "\(count) \(String(localized: "day"))"
        }
        return "\(count) \(String(localized: "days"))"
    }

    static func badgeCount(_ count: Int) -> String {
        if count == 1 {
            return "\(count) \(String(localized: "badge"))"
        }
        return "\(count) \(String(localized: "badges"))"
    }
}
