//
//  AchievementViewModel.swift
//  task
//
//  Created by Samson Oluwapelumi on 08/02/2026.
//

import Foundation

@Observable
final class AchievementViewModel {

    // MARK: - Dependencies

    let store: LearningStore

    // MARK: - Local State

    var isLoading = false
    var errorMessage: String?
    var selectedAchievement: Achievement?
    var showCelebration = false
    var celebratingAchievement: Achievement?
    var selectedCategory: AchievementCategory?
    var showShareSheet = false
    var shareText = ""

    // MARK: - Computed (reactive — reads from shared store)

    var achievements: [Achievement] { store.achievements }

    var earnedAchievements: [Achievement] {
        store.achievements.filter(\.isEarned)
    }

    var lockedAchievements: [Achievement] {
        store.achievements.filter { !$0.isEarned }
    }

    var earnedCount: Int { earnedAchievements.count }

    var totalCount: Int { store.achievements.count }

    var progressFraction: Double {
        guard totalCount > 0 else { return 0 }
        return Double(earnedCount) / Double(totalCount)
    }

    var filteredAchievements: [Achievement] {
        guard let category = selectedCategory else { return store.achievements }
        return store.achievements.filter { $0.category == category }
    }

    var categories: [AchievementCategory] {
        AchievementCategory.allCases
    }

    // MARK: - Stats (for header)

    var completedStagesCount: Int {
        store.learningPath.stages.filter { $0.state == .completed }.count
    }

    var totalStagesCount: Int {
        store.learningPath.stages.count
    }

    var lessonsCompleted: Int {
        store.userProgress.totalLessonsCompleted
    }

    var totalLessons: Int {
        store.learningPath.totalLessons
    }

    var currentStreak: Int {
        store.userProgress.currentStreak
    }

    var longestStreak: Int {
        store.userProgress.longestStreak
    }

    // MARK: - Init

    init(store: LearningStore) {
        self.store = store
    }

    // MARK: - Actions

    /// Simulates initial data fetch.
    func loadAchievements() async {
        isLoading = true
        errorMessage = nil
        try? await Task.sleep(for: .milliseconds(250))
        isLoading = false
    }

    func triggerCelebration(for achievement: Achievement) {
        celebratingAchievement = achievement
        showCelebration = true
    }

    func dismissCelebration() {
        showCelebration = false
        celebratingAchievement = nil
    }

    func shareAchievement(_ achievement: Achievement) -> String {
        "I just earned the \"\(achievement.title)\" badge on Learning Progress! 🎉 \(achievement.description)"
    }

    func prepareShare(for achievement: Achievement) {
        shareText = shareAchievement(achievement)
        showShareSheet = true
    }

    func selectCategory(_ category: AchievementCategory?) {
        if selectedCategory == category {
            selectedCategory = nil
        } else {
            selectedCategory = category
        }
    }

    /// Emoji icon for a category.
    func iconForCategory(_ category: AchievementCategory) -> String {
        switch category {
        case .milestone: return "flag.fill"
        case .streak: return "flame.fill"
        case .mastery: return "star.fill"
        case .special: return "sparkles"
        }
    }
}
