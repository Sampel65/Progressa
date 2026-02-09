//
//  DashboardViewModel.swift
//  task
//
//  Created by Samson Oluwapelumi on 08/02/2026.
//

import Foundation

@Observable
final class DashboardViewModel {

    // MARK: - Dependencies

    let store: LearningStore

    // MARK: - Local State

    var isLoading = false
    var errorMessage: String?

    // MARK: - Computed (reactive — reads from shared store)

    var userProgress: UserProgress { store.userProgress }

    var todayLesson: TodayLesson? { store.todayLesson }

    var learningPath: LearningPath { store.learningPath }

    var recentAchievements: [Achievement] { store.achievements }

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return String(localized: "Good morning")
        case 12..<17: return String(localized: "Good afternoon")
        case 17..<21: return String(localized: "Good evening")
        default: return String(localized: "Good night")
        }
    }

    var motivationalMessage: String {
        let progress = store.userProgress
        if progress.currentStreak >= 7 {
            return String(localized: "Amazing streak! You're on fire! 🔥")
        } else if progress.currentStreak >= 3 {
            return String(localized: "Great momentum! Keep it going! 💪")
        } else if progress.lessonsProgressFraction > 0.5 {
            return String(localized: "Over halfway there! You've got this! 🚀")
        } else if progress.totalLessonsCompleted > 0 {
            return String(localized: "You're closer than you think 💪")
        } else {
            return String(localized: "Let's start your learning journey! 🎯")
        }
    }

    var userName: String {
        store.userProgress.userName
    }

    var currentStage: Stage? {
        store.currentStage
    }

    var earnedBadgesCount: Int {
        store.earnedAchievements.count
    }

    // MARK: - Init

    init(store: LearningStore) {
        self.store = store
    }

    // MARK: - Actions

    /// Simulates an initial data fetch (delay only — store already has data).
    func loadDashboard() async {
        isLoading = true
        errorMessage = nil

        // Simulate network latency
        try? await Task.sleep(for: .milliseconds(300))

        isLoading = false
    }

    /// Complete the current "today" lesson.
    func completeCurrentLesson() {
        guard let lesson = todayLesson else { return }
        store.completeLesson(lessonId: lesson.lesson.id)
    }
}
