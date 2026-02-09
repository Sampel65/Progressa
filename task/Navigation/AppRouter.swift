//
//  AppRouter.swift
//  task
//
//  Created by Samson Oluwapelumi on 08/02/2026.
//

import SwiftUI

// MARK: - Tab Definition

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

// MARK: - Navigation Router

@Observable
final class AppRouter {
    var selectedTab: AppTab = .dashboard
    var dashboardNavigationPath = NavigationPath()
    var learningPathNavigationPath = NavigationPath()
    var achievementNavigationPath = NavigationPath()

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

// MARK: - Navigation Destinations

enum DashboardDestination: Hashable {
    case lessonDetail(Lesson)
    case stageDetail(Stage)
}

enum LearningPathDestination: Hashable {
    case stageDetail(Stage)
    case lessonDetail(Lesson)
}

enum AchievementDestination: Hashable {
    case badgeDetail(Achievement)
}

// Make models Hashable for navigation

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
