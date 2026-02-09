//
//  LearningPathViewModel.swift
//  task
//

import SwiftUI

@Observable
final class LearningPathViewModel {

    // MARK: - Dependencies

    let store: LearningStore

    // MARK: - Local State

    var isLoading = false
    var errorMessage: String?
    var selectedStage: Stage?

    // MARK: - Computed (reactive — reads from shared store)

    var learningPath: LearningPath? { store.learningPath }

    var stages: [Stage] { store.learningPath.stages }

    var overallProgress: Double { store.learningPath.overallProgress }

    var completedStagesCount: Int {
        store.learningPath.stages.filter { $0.state == .completed }.count
    }

    var totalStagesCount: Int {
        store.learningPath.stages.count
    }

    var currentStageNumber: Int {
        stages.first(where: { $0.state == .current })?.stageNumber ?? (completedStagesCount + 1)
    }

    var pathTitle: String { store.learningPath.title }

    var pathDescription: String { store.learningPath.description }

    // MARK: - Init

    init(store: LearningStore) {
        self.store = store
    }

    // MARK: - Actions

    func loadLearningPath() async {
        isLoading = true
        errorMessage = nil

        try? await Task.sleep(for: .milliseconds(300))

        isLoading = false
    }

    func canAccessStage(_ stage: Stage) -> Bool {
        store.canAccessStage(stage)
    }

    func completeLesson(lessonId: UUID) {
        store.completeLesson(lessonId: lessonId)
    }
}
