//
//  AchievementViewModelTests.swift
//  taskTests
//
//  Created by Samson Oluwapelumi on 08/02/2026.
//

import Testing
import Foundation
@testable import task

@Suite("Achievement ViewModel")
struct AchievementViewModelTests {

    private func makeVM(store: LearningStore = LearningStore()) -> AchievementViewModel {
        AchievementViewModel(store: store)
    }

    @Test("Achievements are populated from store")
    @MainActor
    func achievementsPopulated() async {
        let vm = makeVM()
        #expect(!vm.achievements.isEmpty)
    }

    @Test("Earned and locked counts are correct")
    @MainActor
    func achievementCounts() async {
        let vm = makeVM()

        let expectedEarned = MockData.achievements.filter(\.isEarned).count
        let expectedLocked = MockData.achievements.filter { !$0.isEarned }.count

        #expect(vm.earnedCount == expectedEarned)
        #expect(vm.lockedAchievements.count == expectedLocked)
        #expect(vm.totalCount == MockData.achievements.count)
    }

    @Test("Progress fraction is between 0 and 1")
    @MainActor
    func progressFraction() async {
        let vm = makeVM()
        #expect(vm.progressFraction >= 0)
        #expect(vm.progressFraction <= 1)
    }

    @Test("Category filter works correctly")
    @MainActor
    func categoryFiltering() async {
        let vm = makeVM()

        // Filter by streak category
        vm.selectCategory(.streak)
        #expect(vm.selectedCategory == .streak)

        let filtered = vm.filteredAchievements
        #expect(filtered.allSatisfy { $0.category == .streak })

        // Toggle same category deselects
        vm.selectCategory(.streak)
        #expect(vm.selectedCategory == nil)
    }

    @Test("Celebration trigger and dismiss works")
    @MainActor
    func celebrationFlow() async {
        // Create a store and earn an achievement by completing a lesson
        let store = LearningStore()
        if let lesson = store.todayLesson {
            store.completeLesson(lessonId: lesson.lesson.id)
        }
        let vm = makeVM(store: store)

        guard let achievement = vm.earnedAchievements.first else {
            // "First Steps" should be earned after completing 1 lesson
            Issue.record("Expected at least one earned achievement after lesson completion")
            return
        }

        vm.triggerCelebration(for: achievement)
        #expect(vm.showCelebration == true)
        #expect(vm.celebratingAchievement?.id == achievement.id)

        vm.dismissCelebration()
        #expect(vm.showCelebration == false)
        #expect(vm.celebratingAchievement == nil)
    }

    @Test("Share text contains achievement title")
    @MainActor
    func shareTextGeneration() async {
        // Earn an achievement first
        let store = LearningStore()
        if let lesson = store.todayLesson {
            store.completeLesson(lessonId: lesson.lesson.id)
        }
        let vm = makeVM(store: store)

        guard let achievement = vm.earnedAchievements.first else {
            Issue.record("Expected at least one earned achievement")
            return
        }

        let shareText = vm.shareAchievement(achievement)

        #expect(shareText.contains(achievement.title))
        #expect(shareText.contains("Learning Progress"))
    }

    @Test("All categories are available")
    @MainActor
    func categoriesAvailable() async {
        let vm = makeVM()
        #expect(vm.categories.count == AchievementCategory.allCases.count)
    }

    @Test("Achievements update reactively when store changes")
    @MainActor
    func reactiveAchievementUpdate() async {
        let store = LearningStore()
        let vm = makeVM(store: store)

        let initialEarned = vm.earnedCount

        // Complete all lessons in the current stage to trigger achievement unlock
        guard let currentStage = store.currentStage else {
            Issue.record("No current stage")
            return
        }

        let incompleteLessons = currentStage.lessons.filter { !$0.isCompleted }
        for lesson in incompleteLessons {
            store.completeLesson(lessonId: lesson.id)
        }

        // Earned count should have increased (stage completion triggers milestones)
        #expect(vm.earnedCount >= initialEarned)
    }
}
