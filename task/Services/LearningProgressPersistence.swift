//
//  LearningProgressPersistence.swift
//  task
//
//  Created by Samson Oluwapelumi on 07/02/2026.
//


import Foundation

/// Internal structure for encoding/decoding complete learning state to JSON.
private struct PersistedLearningState: Codable {
    let learningPath: LearningPath
    let userProgress: UserProgress
    let achievements: [Achievement]
}

/// Handles persistence of learning progress to disk in Application Support directory.
/// Files are automatically deleted by iOS when the app is uninstalled.
enum LearningProgressPersistence {

    private static let fileName = "learning_progress.json"

    /// Returns the file URL in Application Support/Progressa directory.
    /// Creates the directory if it doesn't exist.
    private static var fileURL: URL {
        let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appSupport = directory.appendingPathComponent("Progressa", isDirectory: true)
        if !FileManager.default.fileExists(atPath: appSupport.path) {
            try? FileManager.default.createDirectory(at: appSupport, withIntermediateDirectories: true)
        }
        return appSupport.appendingPathComponent(fileName)
    }

    /// Loads persisted learning state from disk.
    /// Returns `nil` if file doesn't exist or decoding fails (first launch or corrupted data).
    /// Uses ISO8601 date encoding for proper Date serialization.
    static func load() -> (learningPath: LearningPath, userProgress: UserProgress, achievements: [Achievement])? {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let state = try? decoder.decode(PersistedLearningState.self, from: data) else { return nil }
        return (state.learningPath, state.userProgress, state.achievements)
    }

    /// Saves complete learning state to disk as JSON.
    /// Uses pretty printing and sorted keys for readable/debuggable JSON files.
    /// Silently fails if encoding or writing fails (non-critical operation).
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

    static func clearAll() {
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try? FileManager.default.removeItem(at: fileURL)
        }
        
        let directory = fileURL.deletingLastPathComponent()
        if let contents = try? FileManager.default.contentsOfDirectory(atPath: directory.path),
           contents.isEmpty {
            try? FileManager.default.removeItem(at: directory)
        }
    }
}
