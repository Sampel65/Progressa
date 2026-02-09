//
//  AppRouter.swift
//  task
//
//  Created by Samson Oluwapelumi on 07/02/2026.
//


import SwiftUI

/// Represents the three main tabs in the app's bottom navigation.
enum AppTab: Int, CaseIterable, Identifiable {
    case dashboard
    case learningPath
    case achievements

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .dashboard: String(localized: "Home")
        case .learningPath: "Learn"
        case .achievements: "Awards"
        }
    }

    var iconName: String {
        switch self {
        case .dashboard: "house.fill"
        case .learningPath: "book.fill"
        case .achievements: "trophy.fill"
        }
    }

    var selectedColor: Color {
        switch self {
        case .dashboard: AppColors.primaryIndigo
        case .learningPath: AppColors.primaryIndigo
        case .achievements: AppColors.accentOrange
        }
    }
}


/// Manages tab selection and navigation state for each tab.
/// Maintains separate NavigationPath instances to allow independent navigation stacks per tab.
/// Tapping the same tab twice resets its navigation stack (handled by views).
@Observable
final class AppRouter {
    var selectedTab: AppTab = .dashboard
    var dashboardNavigationPath = NavigationPath()
    var learningPathNavigationPath = NavigationPath()
    var achievementNavigationPath = NavigationPath()

    /// Resets the navigation stack for the currently selected tab.
    /// Used when tapping an already-selected tab to return to root.
    func resetCurrentTab() {
        switch selectedTab {
        case .dashboard:
            dashboardNavigationPath = NavigationPath()
        case .learningPath:
            learningPathNavigationPath = NavigationPath()
        case .achievements:
            achievementNavigationPath = NavigationPath()
        }
    }

    func navigateToLearningPath() {
        selectedTab = .learningPath
    }

    func navigateToAchievements() {
        selectedTab = .achievements
    }
}


/// Navigation destinations for the Dashboard tab.
enum DashboardDestination: Hashable {
    case lessonDetail(Lesson)
    case stageDetail(Stage)
}

/// Navigation destinations for the Learning Path tab.
enum LearningPathDestination: Hashable {
    case stageDetail(Stage)
    case lessonDetail(Lesson)
}

/// Navigation destinations for the Achievements tab.
enum AchievementDestination: Hashable {
    case badgeDetail(Achievement)
}

/// Hashable conformance for navigation. Uses only the ID to ensure stable hashing
/// regardless of other property changes (like completion status).
extension Lesson: Hashable {
    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Stage: Hashable {
    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Achievement: Hashable {
    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
