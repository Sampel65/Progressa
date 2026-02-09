//
//  LearningModels.swift
//  task
//
//  Created by Samson Oluwapelumi on 07/02/2026.
//


import Foundation

/// Represents the completion state of a learning stage.
enum StageState: String, Codable, CaseIterable {
    case completed
    case current
    case locked
}

/// Represents the unlock state of an achievement badge.
enum BadgeState: String, Codable {
    case earned
    case locked
}

/// Represents a single lesson within a learning stage.
struct Lesson: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let subtitle: String
    let durationMinutes: Int
    var isCompleted: Bool
    let iconName: String

    /// Returns a formatted duration string for display (e.g., "25 min").
    var formattedDuration: String {
        "\(durationMinutes) min"
    }
}

/// Represents a stage containing multiple lessons in the learning path.
/// Stages progress from locked → current → completed as the user advances.
struct Stage: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let description: String
    var state: StageState
    var lessons: [Lesson]
    let badgeIconName: String
    let stageNumber: Int

    /// Count of completed lessons in this stage.
    var completedLessonsCount: Int {
        lessons.filter(\.isCompleted).count
    }

    /// Progress fraction from 0.0 to 1.0 based on completed lessons.
    var progressFraction: Double {
        guard !lessons.isEmpty else { return 0 }
        return Double(completedLessonsCount) / Double(lessons.count)
    }

    /// Convenience property checking if stage is fully completed.
    var isFullyCompleted: Bool {
        state == .completed
    }
}


/// Represents the complete learning path with all stages and lessons.
/// Provides computed properties for progress tracking and navigation.
struct LearningPath: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let description: String
    var stages: [Stage]

    /// Index of the currently active stage (first stage with .current state).
    var currentStageIndex: Int {
        stages.firstIndex(where: { $0.state == .current }) ?? 0
    }

    /// Total count of all lessons across all stages.
    var totalLessons: Int {
        stages.reduce(0) { $0 + $1.lessons.count }
    }

    /// Total count of completed lessons across all stages.
    var completedLessons: Int {
        stages.reduce(0) { $0 + $1.completedLessonsCount }
    }

    /// Overall progress fraction from 0.0 to 1.0 across all lessons.
    var overallProgress: Double {
        guard totalLessons > 0 else { return 0 }
        return Double(completedLessons) / Double(totalLessons)
    }

    /// Count of completed stages.
    var completedStages: Int {
        stages.filter { $0.state == .completed }.count
    }
}

/// Represents an achievement badge that can be earned through learning milestones.
struct Achievement: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let description: String
    let iconName: String
    let state: BadgeState
    let earnedDate: Date?
    let category: AchievementCategory

    /// Convenience property checking if achievement has been earned.
    var isEarned: Bool {
        state == .earned
    }
}

enum AchievementCategory: String, Codable, CaseIterable {
    case milestone = "Milestone"
    case streak = "Streak"
    case mastery = "Mastery"
    case special = "Special"

    var localizedTitle: String {
        switch self {
        case .milestone: return "Milestone"
        case .streak: return "Streak"
        case .mastery: return "Mastery"
        case .special: return "Special"
        }
    }
}


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


struct TodayLesson: Identifiable, Equatable {
    let id: UUID
    let lesson: Lesson
    let stageName: String
    let stageNumber: Int
    let lessonIndex: Int
    let totalLessonsInStage: Int
}
