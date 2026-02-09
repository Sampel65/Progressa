//
//  LearningProgressPersistence.swift
//  task
//

import Foundation

// MARK: - Persisted State

private struct PersistedLearningState: Codable {
    let learningPath: LearningPath
    let userProgress: UserProgress
    let achievements: [Achievement]
}

// MARK: - Learning Progress Persistence

enum LearningProgressPersistence {

    private static let fileName = "learning_progress.json"

    private static var fileURL: URL {
        let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appSupport = directory.appendingPathComponent("Progressa", isDirectory: true)
        if !FileManager.default.fileExists(atPath: appSupport.path) {
            try? FileManager.default.createDirectory(at: appSupport, withIntermediateDirectories: true)
        }
        return appSupport.appendingPathComponent(fileName)
    }

    static func load() -> (learningPath: LearningPath, userProgress: UserProgress, achievements: [Achievement])? {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let state = try? decoder.decode(PersistedLearningState.self, from: data) else { return nil }
        return (state.learningPath, state.userProgress, state.achievements)
    }

    static func save(learningPath: LearningPath, userProgress: UserProgress, achievements: [Achievement]) {
        let state = PersistedLearningState(
            learningPath: learningPath,
            userProgress: userProgress,
            achievements: achievements
        )
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(state) else { return }
        try? data.write(to: fileURL)
    }
}
