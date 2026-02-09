//
//  LearningModels.swift
//  task
//
//  Created by Samson Oluwapelumi on 08/02/2026.
//

import Foundation

// MARK: - Stage Completion State

enum StageState: String, Codable, CaseIterable {
    case completed
    case current
    case locked
}

// MARK: - Badge State

enum BadgeState: String, Codable {
    case earned
    case locked
}

// MARK: - Lesson

struct Lesson: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let subtitle: String
    let durationMinutes: Int
    var isCompleted: Bool
    let iconName: String

    var formattedDuration: String {
        "\(durationMinutes) min"
    }
}

// MARK: - Stage

struct Stage: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let description: String
    var state: StageState
    var lessons: [Lesson]
    let badgeIconName: String
    let stageNumber: Int

    var completedLessonsCount: Int {
        lessons.filter(\.isCompleted).count
    }

    var progressFraction: Double {
        guard !lessons.isEmpty else { return 0 }
        return Double(completedLessonsCount) / Double(lessons.count)
    }

    var isFullyCompleted: Bool {
        state == .completed
    }
}

// MARK: - Learning Path

struct LearningPath: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let description: String
    var stages: [Stage]

    var currentStageIndex: Int {
        stages.firstIndex(where: { $0.state == .current }) ?? 0
    }

    var totalLessons: Int {
        stages.reduce(0) { $0 + $1.lessons.count }
    }

    var completedLessons: Int {
        stages.reduce(0) { $0 + $1.completedLessonsCount }
    }

    var overallProgress: Double {
        guard totalLessons > 0 else { return 0 }
        return Double(completedLessons) / Double(totalLessons)
    }

    var completedStages: Int {
        stages.filter { $0.state == .completed }.count
    }
}

// MARK: - Achievement

struct Achievement: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let description: String
    let iconName: String
    let state: BadgeState
    let earnedDate: Date?
    let category: AchievementCategory

    var isEarned: Bool {
        state == .earned
    }
}

enum AchievementCategory: String, Codable, CaseIterable {
    case milestone = "Milestone"
    case streak = "Streak"
    case mastery = "Mastery"
    case special = "Special"

    /// Display title for UI (English only).
    var localizedTitle: String {
        switch self {
        case .milestone: return "Milestone"
        case .streak: return "Streak"
        case .mastery: return "Mastery"
        case .special: return "Special"
        }
    }
}

// MARK: - User Progress

struct UserProgress: Codable, Equatable {
    var currentStreak: Int
    var longestStreak: Int
    var totalLessonsCompleted: Int
    var totalLessons: Int
    var achievementsEarned: Int
    var totalAchievements: Int
    var lastActiveDate: Date
    var userName: String

    var lessonsProgressFraction: Double {
        guard totalLessons > 0 else { return 0 }
        return Double(totalLessonsCompleted) / Double(totalLessons)
    }

    var achievementsProgressFraction: Double {
        guard totalAchievements > 0 else { return 0 }
        return Double(achievementsEarned) / Double(totalAchievements)
    }
}

// MARK: - Today's Lesson

struct TodayLesson: Identifiable, Equatable {
    let id: UUID
    let lesson: Lesson
    let stageName: String
    let stageNumber: Int
    let lessonIndex: Int
    let totalLessonsInStage: Int
}
