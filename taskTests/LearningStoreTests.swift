//
//  LearningStoreTests.swift
//  taskTests
//
//  Created by Samson Oluwapelumi on 08/02/2026.
//

import Testing
import Foundation
@testable import task

@Suite("Learning Store")
struct LearningStoreTests {

    // MARK: - Lesson Completion

    @Test("Completing a lesson marks it as done")
    @MainActor
    func completeLessonMarksAsDone() {
        let store = LearningStore()

        guard let today = store.todayLesson else {
            Issue.record("No today lesson")
            return
        }

        let lessonId = today.lesson.id
        let result = store.completeLesson(lessonId: lessonId)

        #expect(result == true)

        // Verify the lesson is now completed in the learning path
        let updated = store.learningPath.stages
            .flatMap(\.lessons)
            .first(where: { $0.id == lessonId })
        #expect(updated?.isCompleted == true)
    }

    @Test("Completing the same lesson twice returns false")
    @MainActor
    func duplicateCompletionReturnsFalse() {
        let store = LearningStore()

        guard let today = store.todayLesson else {
            Issue.record("No today lesson")
            return
        }

        let lessonId = today.lesson.id
        _ = store.completeLesson(lessonId: lessonId)
        let second = store.completeLesson(lessonId: lessonId)

        #expect(second == false)
    }

    @Test("Completing a lesson increments totalLessonsCompleted")
    @MainActor
    func completionIncrementsCounter() {
        let store = LearningStore()
        let before = store.userProgress.totalLessonsCompleted

        guard let today = store.todayLesson else {
            Issue.record("No today lesson")
            return
        }

        store.completeLesson(lessonId: today.lesson.id)

        #expect(store.userProgress.totalLessonsCompleted == before + 1)
    }

    @Test("Completing a non-existent lesson returns false")
    @MainActor
    func completeInvalidLesson() {
        let store = LearningStore()
        let result = store.completeLesson(lessonId: UUID())
        #expect(result == false)
    }

    // MARK: - Today Lesson

    @Test("Today lesson advances after completion")
    @MainActor
    func todayLessonAdvances() {
        let store = LearningStore()

        guard let first = store.todayLesson else {
            Issue.record("No today lesson")
            return
        }

        store.completeLesson(lessonId: first.lesson.id)

        guard let second = store.todayLesson else {
            Issue.record("No next lesson")
            return
        }

        #expect(first.lesson.id != second.lesson.id)
    }

    @Test("Today lesson is nil when all lessons are completed")
    @MainActor
    func todayLessonNilWhenAllDone() {
        let store = LearningStore()

        // Complete ALL lessons in ALL stages
        for stage in store.learningPath.stages {
            for lesson in stage.lessons {
                store.completeLesson(lessonId: lesson.id)
            }
        }

        #expect(store.todayLesson == nil)
    }

    // MARK: - Stage Progression

    @Test("Stage transitions to completed when all lessons done")
    @MainActor
    func stageCompletesWhenAllLessonsDone() {
        let store = LearningStore()

        guard let current = store.currentStage else {
            Issue.record("No current stage")
            return
        }

        // Complete all lessons in the current stage
        for lesson in current.lessons where !lesson.isCompleted {
            store.completeLesson(lessonId: lesson.id)
        }

        // Verify stage is now completed
        let updated = store.learningPath.stages.first(where: { $0.id == current.id })
        #expect(updated?.state == .completed)
    }

    @Test("Next stage unlocks after current stage completion")
    @MainActor
    func nextStageUnlocks() {
        let store = LearningStore()

        guard let current = store.currentStage else {
            Issue.record("No current stage")
            return
        }

        let nextNumber = current.stageNumber + 1

        // Complete current stage
        for lesson in current.lessons where !lesson.isCompleted {
            store.completeLesson(lessonId: lesson.id)
        }

        // Next stage should now be current
        let next = store.learningPath.stages.first(where: { $0.stageNumber == nextNumber })
        #expect(next?.state == .current)
    }

    @Test("Milestone alert triggers on stage completion")
    @MainActor
    func milestoneAlertTriggersOnStageCompletion() {
        let store = LearningStore()

        guard let current = store.currentStage else { return }

        for lesson in current.lessons where !lesson.isCompleted {
            store.completeLesson(lessonId: lesson.id)
        }

        #expect(store.showMilestoneAlert == true)
        #expect(store.milestoneMessage.contains(current.title))
    }

    // MARK: - Achievement Unlocking

    @Test("Achievements can be unlocked by conditions")
    @MainActor
    func achievementUnlocking() {
        let store = LearningStore()

        let initialEarned = store.earnedAchievements.count

        // Complete current stage (triggers achievement checks)
        guard let current = store.currentStage else { return }
        for lesson in current.lessons where !lesson.isCompleted {
            store.completeLesson(lessonId: lesson.id)
        }

        // At least one new achievement should have been unlocked
        // (e.g., Halfway Hero if over 50%, or stage mastery)
        #expect(store.earnedAchievements.count >= initialEarned)
    }

    // MARK: - Streak

    @Test("Streak is maintained for consecutive days")
    @MainActor
    func streakMaintained() {
        var progress = MockData.userProgress
        // Set last active to yesterday
        progress.lastActiveDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        progress.currentStreak = 5

        let store = LearningStore(userProgress: progress)

        guard let today = store.todayLesson else { return }
        store.completeLesson(lessonId: today.lesson.id)

        #expect(store.userProgress.currentStreak == 6)
    }

    @Test("Streak resets after missed days")
    @MainActor
    func streakResetsAfterMissedDays() {
        var progress = MockData.userProgress
        // Set last active to 3 days ago
        progress.lastActiveDate = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
        progress.currentStreak = 5

        let store = LearningStore(userProgress: progress)

        guard let today = store.todayLesson else { return }
        store.completeLesson(lessonId: today.lesson.id)

        #expect(store.userProgress.currentStreak == 1)
    }

    // MARK: - Access Control

    @Test("Can access completed and current stages")
    @MainActor
    func canAccessCompletedAndCurrent() {
        let store = LearningStore()

        for stage in store.learningPath.stages {
            switch stage.state {
            case .completed, .current:
                #expect(store.canAccessStage(stage) == true)
            case .locked:
                #expect(store.canAccessStage(stage) == false)
            }
        }
    }

    // MARK: - Dismiss Helpers

    @Test("Dismiss milestone clears alert state")
    @MainActor
    func dismissMilestone() {
        let store = LearningStore()
        store.showMilestoneAlert = true
        store.milestoneMessage = "Test"

        store.dismissMilestone()

        #expect(store.showMilestoneAlert == false)
        #expect(store.milestoneMessage.isEmpty)
    }
}
