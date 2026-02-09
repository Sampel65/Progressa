//
//  DependencyContainer.swift
//  task
//
//  Created by Samson Oluwapelumi on 07/02/2026.
//


import SwiftUI

/// Dependency injection container that provides shared instances of stores and services.
/// Centralizes dependency management and enables easy testing through dependency substitution.
@Observable
final class DependencyContainer {

    /// Shared authentication store instance.
    let authStore: AuthStore

    /// Shared learning store instance (single source of truth for learning data).
    let store: LearningStore

    /// Service protocol for learning data access (currently mocked, can be swapped for API).
    let learningService: LearningServiceProtocol

    /// Initializes the container with default implementations or test doubles.
    init(
        authStore: AuthStore = AuthStore(),
        store: LearningStore = LearningStore(),
        learningService: LearningServiceProtocol = MockLearningService()
    ) {
        self.authStore = authStore
        self.store = store
        self.learningService = learningService
    }

    /// Factory method for creating DashboardViewModel with the shared store.
    func makeDashboardViewModel() -> DashboardViewModel {
        DashboardViewModel(store: store)
    }

    /// Factory method for creating LearningPathViewModel with the shared store.
    func makeLearningPathViewModel() -> LearningPathViewModel {
        LearningPathViewModel(store: store)
    }

    /// Factory method for creating AchievementViewModel with the shared store.
    func makeAchievementViewModel() -> AchievementViewModel {
        AchievementViewModel(store: store)
    }
}


private struct DependencyContainerKey: EnvironmentKey {
    static let defaultValue = DependencyContainer()
}

extension EnvironmentValues {
    var dependencies: DependencyContainer {
        get { self[DependencyContainerKey.self] }
        set { self[DependencyContainerKey.self] = newValue }
    }
}
