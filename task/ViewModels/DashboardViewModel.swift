//
//  DashboardViewModel.swift
//  task
//
//  Created by Samson Oluwapelumi on 08/02/2026.
//


import Foundation

/// ViewModel for the Dashboard screen.
/// Exposes computed properties that read from the shared LearningStore.
/// Handles UI-specific logic like time-based greetings and motivational messages.
@Observable
final class DashboardViewModel {

    /// Reference to the shared learning store (single source of truth).
    let store: LearningStore

    /// Loading state for async operations (currently unused but available for future API calls).
    var isLoading = false
    
    /// Error message to display if operations fail.
    var errorMessage: String?

    /// All computed properties delegate directly to the store for reactive updates.
    var userProgress: UserProgress { store.userProgress }

    var todayLesson: TodayLesson? { store.todayLesson }

    var learningPath: LearningPath { store.learningPath }

    var recentAchievements: [Achievement] { store.achievements }

    /// Returns a time-appropriate greeting based on current hour.
    /// Morning: 5-11, Afternoon: 12-16, Evening: 17-20, Night: 21-4.
    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return String(localized: "Good morning")
        case 12..<17: return String(localized: "Good afternoon")
        case 17..<21: return String(localized: "Good evening")
        default: return String(localized: "Good night")
        }
    }

    /// Generates a contextual motivational message based on user progress.
    /// Prioritizes streak achievements, then progress milestones, then encouragement for beginners.
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


    init(store: LearningStore) {
        self.store = store
    }


    func loadDashboard() async {
        isLoading = true
        errorMessage = nil

        try? await Task.sleep(for: .milliseconds(300))

        isLoading = false
    }

    func completeCurrentLesson() {
        guard let lesson = todayLesson else { return }
        store.completeLesson(lessonId: lesson.lesson.id)
    }
}
