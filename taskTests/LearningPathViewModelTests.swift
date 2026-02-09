//
//  LearningPathViewModelTests.swift
//  taskTests
//
//  Created by Samson Oluwapelumi on 08/02/2026.
//

import Testing
import Foundation
@testable import task

@Suite("Learning Path ViewModel")
struct LearningPathViewModelTests {

    private func makeVM(store: LearningStore = LearningStore()) -> LearningPathViewModel {
        LearningPathViewModel(store: store)
    }

    @Test("Stages are populated from store")
    @MainActor
    func stagesPopulated() async {
        let vm = makeVM()
        #expect(!vm.stages.isEmpty)
    }

    @Test("Overall progress is correctly calculated")
    @MainActor
    func overallProgressCalculation() async {
        let vm = makeVM()
        #expect(vm.overallProgress >= 0)
        #expect(vm.overallProgress <= 1)
    }

    @Test("Completed stages count is accurate")
    @MainActor
    func completedStagesCount() async {
        let vm = makeVM()
        let expectedCompleted = MockData.learningPath.stages.filter { $0.state == .completed }.count
        #expect(vm.completedStagesCount == expectedCompleted)
    }

    @Test("Total stages count is correct")
    @MainActor
    func totalStagesCount() async {
        let vm = makeVM()
        #expect(vm.totalStagesCount == MockData.learningPath.stages.count)
    }

    @Test("Locked stages cannot be accessed")
    @MainActor
    func lockedStageAccess() async {
        let vm = makeVM()
        let lockedStage = vm.stages.first(where: { $0.state == .locked })
        if let locked = lockedStage {
            #expect(!vm.canAccessStage(locked))
        }
    }

    @Test("Completed and current stages can be accessed")
    @MainActor
    func accessibleStages() async {
        let vm = makeVM()

        let completedStage = vm.stages.first(where: { $0.state == .completed })
        if let completed = completedStage {
            #expect(vm.canAccessStage(completed))
        }

        let currentStage = vm.stages.first(where: { $0.state == .current })
        if let current = currentStage {
            #expect(vm.canAccessStage(current))
        }
    }

    @Test("Path title and description are populated")
    @MainActor
    func pathMetadata() async {
        let vm = makeVM()
        #expect(!vm.pathTitle.isEmpty)
        #expect(!vm.pathDescription.isEmpty)
    }

    @Test("Completing all lessons in a stage progresses to next")
    @MainActor
    func stageProgression() async {
        let store = LearningStore()
        let vm = makeVM(store: store)

        // Find the current stage and complete all its lessons
        guard let currentStage = vm.stages.first(where: { $0.state == .current }) else {
            Issue.record("No current stage found")
            return
        }

        let incompleteLessons = currentStage.lessons.filter { !$0.isCompleted }
        for lesson in incompleteLessons {
            store.completeLesson(lessonId: lesson.id)
        }

        // The stage should now be completed
        let updatedStage = vm.stages.first(where: { $0.id == currentStage.id })
        #expect(updatedStage?.state == .completed)

        // The next stage should be current
        let nextStageNumber = currentStage.stageNumber + 1
        let nextStage = vm.stages.first(where: { $0.stageNumber == nextStageNumber })
        #expect(nextStage?.state == .current)
    }

    @Test("Completing a lesson updates progress")
    @MainActor
    func lessonCompletionUpdatesProgress() async {
        let store = LearningStore()
        let vm = makeVM(store: store)

        let before = vm.overallProgress

        if let lesson = store.todayLesson {
            vm.completeLesson(lessonId: lesson.lesson.id)
        }

        #expect(vm.overallProgress > before)
    }
}
