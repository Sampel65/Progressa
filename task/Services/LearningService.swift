//
//  LearningService.swift
//  task
//
//  Created by Samson Oluwapelumi on 08/02/2026.
//

import Foundation

// MARK: - Learning Service Protocol

protocol LearningServiceProtocol: Sendable {
    func fetchLearningPath() async -> LearningPath
    func fetchUserProgress() async -> UserProgress
    func fetchAchievements() async -> [Achievement]
    func fetchTodayLesson() async -> TodayLesson
    func completeLesson(lessonId: UUID) async -> Bool
    func unlockAchievement(achievementId: UUID) async -> Achievement?
}

// MARK: - Mock Learning Service

final class MockLearningService: LearningServiceProtocol {

    func fetchLearningPath() async -> LearningPath {
        // Simulate network delay
        try? await Task.sleep(for: .milliseconds(300))
        return MockData.learningPath
    }

    func fetchUserProgress() async -> UserProgress {
        try? await Task.sleep(for: .milliseconds(200))
        return MockData.userProgress
    }

    func fetchAchievements() async -> [Achievement] {
        try? await Task.sleep(for: .milliseconds(250))
        return MockData.achievements
    }

    func fetchTodayLesson() async -> TodayLesson {
        try? await Task.sleep(for: .milliseconds(150))
        return MockData.todayLesson
    }

    func completeLesson(lessonId: UUID) async -> Bool {
        try? await Task.sleep(for: .milliseconds(500))
        return true
    }

    func unlockAchievement(achievementId: UUID) async -> Achievement? {
        try? await Task.sleep(for: .milliseconds(300))
        return MockData.achievements.first(where: { $0.id == achievementId })
    }
}
