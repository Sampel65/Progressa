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

/// Manages persistence of learning progress data.
/// 
/// Files stored in Application Support are automatically deleted by iOS
/// when the app is uninstalled from the device.
enum LearningProgressPersistence {

    private static let fileName = "learning_progress.json"

    private static var fileURL: URL {
        // Files in Application Support are automatically deleted when app is uninstalled
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

    /// Deletes all persisted learning progress data.
    /// This is automatically called when the app is deleted, but can also be called manually.
    static func clearAll() {
        // Delete the progress file
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try? FileManager.default.removeItem(at: fileURL)
        }
        
        // Also delete the Progressa directory if it's empty
        let directory = fileURL.deletingLastPathComponent()
        if let contents = try? FileManager.default.contentsOfDirectory(atPath: directory.path),
           contents.isEmpty {
            try? FileManager.default.removeItem(at: directory)
        }
    }
}
