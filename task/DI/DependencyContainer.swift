//
//  DependencyContainer.swift
//  task
//
//  Created by Samson Oluwapelumi on 08/02/2026.
//

import SwiftUI

// ═══════════════════════════════════════════════════════
// MARK: - Dependency Container
// ═══════════════════════════════════════════════════════

/// IoC container that provides shared dependencies.
///
/// The `store` is the single source of truth for all learning data.
/// The `authStore` manages authentication state and credential storage.
/// Every ViewModel receives the store, ensuring reactive updates propagate
/// across the entire app (Dashboard, Learning Path, Achievements).
@Observable
final class DependencyContainer {

    /// Authentication state manager — persists credentials via Keychain.
    let authStore: AuthStore

    /// Shared mutable data store — all ViewModels read/write through this.
    let store: LearningStore

    /// Protocol-based service for architectural demonstration.
    /// Used by unit tests that need to stub network behaviour.
    let learningService: LearningServiceProtocol

    init(
        authStore: AuthStore = AuthStore(),
        store: LearningStore = LearningStore(),
        learningService: LearningServiceProtocol = MockLearningService()
    ) {
        self.authStore = authStore
        self.store = store
        self.learningService = learningService
    }

    // MARK: - ViewModel Factories

    func makeDashboardViewModel() -> DashboardViewModel {
        DashboardViewModel(store: store)
    }

    func makeLearningPathViewModel() -> LearningPathViewModel {
        LearningPathViewModel(store: store)
    }

    func makeAchievementViewModel() -> AchievementViewModel {
        AchievementViewModel(store: store)
    }
}

// ═══════════════════════════════════════════════════════
// MARK: - Environment Key
// ═══════════════════════════════════════════════════════

private struct DependencyContainerKey: EnvironmentKey {
    static let defaultValue = DependencyContainer()
}

extension EnvironmentValues {
    var dependencies: DependencyContainer {
        get { self[DependencyContainerKey.self] }
        set { self[DependencyContainerKey.self] = newValue }
    }
}
