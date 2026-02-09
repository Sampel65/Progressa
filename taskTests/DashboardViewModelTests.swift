//
//  DashboardViewModelTests.swift
//  taskTests
//
//  Created by Samson Oluwapelumi on 08/02/2026.
//

import Testing
import Foundation
@testable import task

// MARK: - Dashboard ViewModel Tests

@Suite("Dashboard ViewModel")
struct DashboardViewModelTests {

    private func makeVM(store: LearningStore = LearningStore()) -> DashboardViewModel {
        DashboardViewModel(store: store)
    }

    @Test("Load dashboard completes without error")
    @MainActor
    func loadDashboard() async {
        let vm = makeVM()
        await vm.loadDashboard()

        #expect(vm.isLoading == false)
        #expect(vm.errorMessage == nil)
    }

    @Test("Greeting is time-dependent")
    @MainActor
    func greetingMessage() async {
        let vm = makeVM()
        let validGreetings = ["Good morning", "Good afternoon", "Good evening", "Good night"]
        #expect(validGreetings.contains(vm.greeting))
    }

    @Test("User name comes from store")
    @MainActor
    func userNameFromStore() async {
        let vm = makeVM()
        #expect(vm.userName == MockData.userProgress.userName)
    }

    @Test("Today lesson is populated from store")
    @MainActor
    func todayLessonPopulated() async {
        let vm = makeVM()
        #expect(vm.todayLesson != nil)
        #expect(vm.todayLesson?.lesson.isCompleted == false)
    }

    @Test("Motivational message reflects streak status")
    @MainActor
    func motivationalMessageForStreak() async {
        var progress = MockData.userProgress
        progress.currentStreak = 7
        let store = LearningStore(userProgress: progress)
        let vm = makeVM(store: store)

        #expect(vm.motivationalMessage.contains("streak") || vm.motivationalMessage.contains("fire") || vm.motivationalMessage.contains("Amazing"))
    }

    @Test("Current stage is correctly identified")
    @MainActor
    func currentStageIdentification() async {
        let vm = makeVM()
        #expect(vm.currentStage != nil)
        #expect(vm.currentStage?.state == .current)
    }

    @Test("Earned badges count is correct")
    @MainActor
    func earnedBadgesCount() async {
        let vm = makeVM()
        let expectedCount = MockData.achievements.filter(\.isEarned).count
        #expect(vm.earnedBadgesCount == expectedCount)
    }

    @Test("Completing a lesson updates today lesson")
    @MainActor
    func completeLessonUpdatesToday() async {
        let store = LearningStore()
        let vm = makeVM(store: store)

        let before = vm.todayLesson?.lesson.id
        vm.completeCurrentLesson()
        let after = vm.todayLesson?.lesson.id

        // Today lesson should advance to the next one
        #expect(before != after)
    }

    @Test("Completing a lesson increments progress")
    @MainActor
    func completeLessonIncrementsProgress() async {
        let store = LearningStore()
        let vm = makeVM(store: store)

        let beforeCount = vm.userProgress.totalLessonsCompleted
        vm.completeCurrentLesson()
        let afterCount = vm.userProgress.totalLessonsCompleted

        #expect(afterCount == beforeCount + 1)
    }
}
