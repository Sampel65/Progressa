//
//  ModelTests.swift
//  taskTests
//
//  Created by Samson Oluwapelumi on 08/02/2026.
//

import Testing
import Foundation
@testable import task

@Suite("Learning Models")
struct ModelTests {

    // MARK: - Lesson Tests

    @Test("Lesson formatted duration is correct")
    func lessonDuration() {
        let lesson = Lesson(
            id: UUID(),
            title: "Test",
            subtitle: "Sub",
            durationMinutes: 25,
            isCompleted: false,
            iconName: "star"
        )
        #expect(lesson.formattedDuration == "25 min")
    }

    // MARK: - Stage Tests

    @Test("Stage progress fraction calculates correctly")
    func stageProgress() {
        let lessons = [
            Lesson(id: UUID(), title: "L1", subtitle: "", durationMinutes: 10, isCompleted: true, iconName: "star"),
            Lesson(id: UUID(), title: "L2", subtitle: "", durationMinutes: 10, isCompleted: true, iconName: "star"),
            Lesson(id: UUID(), title: "L3", subtitle: "", durationMinutes: 10, isCompleted: false, iconName: "star"),
            Lesson(id: UUID(), title: "L4", subtitle: "", durationMinutes: 10, isCompleted: false, iconName: "star"),
        ]

        let stage = Stage(
            id: UUID(),
            title: "Test Stage",
            description: "Desc",
            state: .current,
            lessons: lessons,
            badgeIconName: "star",
            stageNumber: 1
        )

        #expect(stage.completedLessonsCount == 2)
        #expect(stage.progressFraction == 0.5)
        #expect(!stage.isFullyCompleted)
    }

    @Test("Completed stage is fully completed")
    func completedStage() {
        let stage = Stage(
            id: UUID(),
            title: "Done",
            description: "",
            state: .completed,
            lessons: [],
            badgeIconName: "star",
            stageNumber: 1
        )
        #expect(stage.isFullyCompleted)
    }

    @Test("Stage with no lessons has zero progress")
    func emptyStageProgress() {
        let stage = Stage(
            id: UUID(),
            title: "Empty",
            description: "",
            state: .locked,
            lessons: [],
            badgeIconName: "star",
            stageNumber: 1
        )
        #expect(stage.progressFraction == 0)
    }

    // MARK: - Learning Path Tests

    @Test("Learning path overall progress is correct")
    func pathProgress() {
        let path = MockData.learningPath
        let totalLessons = path.totalLessons
        let completedLessons = path.completedLessons

        #expect(totalLessons > 0)
        #expect(completedLessons > 0)
        #expect(path.overallProgress == Double(completedLessons) / Double(totalLessons))
    }

    @Test("Learning path current stage index is correct")
    func currentStageIndex() {
        let path = MockData.learningPath
        let currentIndex = path.currentStageIndex
        #expect(path.stages[currentIndex].state == .current)
    }

    @Test("Learning path completed stages count")
    func completedStagesCount() {
        let path = MockData.learningPath
        let completed = path.completedStages
        #expect(completed == path.stages.filter { $0.state == .completed }.count)
    }

    // MARK: - User Progress Tests

    @Test("User progress fractions are in valid range")
    func progressFractions() {
        let progress = MockData.userProgress

        #expect(progress.lessonsProgressFraction >= 0)
        #expect(progress.lessonsProgressFraction <= 1)
        #expect(progress.achievementsProgressFraction >= 0)
        #expect(progress.achievementsProgressFraction <= 1)
    }

    // MARK: - Achievement Tests

    @Test("Achievement isEarned matches state")
    func achievementEarnedState() {
        let earned = Achievement(
            id: UUID(), title: "Test", description: "",
            iconName: "star", state: .earned, earnedDate: Date(),
            category: .milestone
        )
        let locked = Achievement(
            id: UUID(), title: "Test", description: "",
            iconName: "star", state: .locked, earnedDate: nil,
            category: .milestone
        )

        #expect(earned.isEarned == true)
        #expect(locked.isEarned == false)
    }

    // MARK: - Mock Data Integrity

    @Test("Mock data today lesson references valid stage and lesson")
    func todayLessonValidity() {
        let today = MockData.todayLesson
        #expect(today.lessonIndex > 0)
        #expect(today.lessonIndex <= today.totalLessonsInStage)
        #expect(!today.lesson.isCompleted)
    }

    @Test("Mock achievements have both earned and locked badges")
    func mockAchievementVariety() {
        let achievements = MockData.achievements
        let earnedCount = achievements.filter(\.isEarned).count
        let lockedCount = achievements.filter { !$0.isEarned }.count

        #expect(earnedCount > 0)
        #expect(lockedCount > 0)
    }
}
