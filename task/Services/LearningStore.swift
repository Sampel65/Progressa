//
//  LearningStore.swift
//  task
//

import Foundation

// MARK: - Learning Store

@Observable
final class LearningStore {

    // MARK: - Core Data

    private(set) var learningPath: LearningPath
    private(set) var userProgress: UserProgress
    private(set) var achievements: [Achievement]

    // MARK: - Events

    var recentlyCompletedLesson: Lesson?
    var recentlyUnlockedAchievements: [Achievement] = []
    var showMilestoneAlert = false
    var milestoneMessage = ""

    // MARK: - Init

    init(
        learningPath: LearningPath = MockData.learningPath,
        userProgress: UserProgress = MockData.userProgress,
        achievements: [Achievement] = MockData.achievements
    ) {
        if let saved = LearningProgressPersistence.load() {
            self.learningPath = saved.learningPath
            self.userProgress = saved.userProgress
            self.achievements = saved.achievements
        } else {
            self.learningPath = learningPath
            self.userProgress = userProgress
            self.achievements = achievements
        }
    }

    // MARK: - Computed

    var todayLesson: TodayLesson? {
        guard let currentStage = learningPath.stages.first(where: { $0.state == .current }) else {
            return nil
        }
        guard let nextLesson = currentStage.lessons.first(where: { !$0.isCompleted }) else {
            return nil
        }
        let lessonIndex = (currentStage.lessons.firstIndex(where: { $0.id == nextLesson.id }) ?? 0) + 1
        return TodayLesson(
            id: nextLesson.id,
            lesson: nextLesson,
            stageName: currentStage.title,
            stageNumber: currentStage.stageNumber,
            lessonIndex: lessonIndex,
            totalLessonsInStage: currentStage.lessons.count
        )
    }

    var currentStage: Stage? {
        learningPath.stages.first(where: { $0.state == .current })
    }

    var earnedAchievements: [Achievement] {
        achievements.filter(\.isEarned)
    }

    // MARK: - Mutations

    @discardableResult
    func completeLesson(lessonId: UUID) -> Bool {
        guard let (stageIdx, lessonIdx) = findLesson(id: lessonId) else { return false }

        if learningPath.stages[stageIdx].lessons[lessonIdx].isCompleted { return false }

        learningPath.stages[stageIdx].lessons[lessonIdx].isCompleted = true
        recentlyCompletedLesson = learningPath.stages[stageIdx].lessons[lessonIdx]

        userProgress.totalLessonsCompleted += 1

        checkStageCompletion(stageIdx: stageIdx)

        let unlocked = checkAndUnlockAchievements()
        recentlyUnlockedAchievements = unlocked

        updateStreak()

        userProgress.totalLessons = learningPath.totalLessons
        userProgress.achievementsEarned = achievements.filter(\.isEarned).count
        userProgress.totalAchievements = achievements.count

        persist()

        return true
    }

    // MARK: - Stage Completion

    private func checkStageCompletion(stageIdx: Int) {
        let stage = learningPath.stages[stageIdx]

        let allDone = stage.lessons.allSatisfy(\.isCompleted)
        guard allDone, stage.state == .current else { return }

        learningPath.stages[stageIdx].state = .completed

        let nextIdx = stageIdx + 1
        if nextIdx < learningPath.stages.count,
           learningPath.stages[nextIdx].state == .locked {
            learningPath.stages[nextIdx].state = .current
        }

        milestoneMessage = "🎉 You completed \"\(stage.title)\"!"
        showMilestoneAlert = true
    }

    // MARK: - Achievement Engine

    private func checkAndUnlockAchievements() -> [Achievement] {
        var newlyUnlocked: [Achievement] = []

        let totalCompleted = userProgress.totalLessonsCompleted
        let totalLessons = learningPath.totalLessons
        let completedStages = learningPath.stages.filter { $0.state == .completed }.count
        let totalStages = learningPath.stages.count
        let streak = userProgress.currentStreak

        for i in achievements.indices {
            guard achievements[i].state == .locked else { continue }

            var shouldUnlock = false

            switch achievements[i].title {
            case "First Steps":
                shouldUnlock = totalCompleted >= 1
            case "Halfway Hero":
                shouldUnlock = totalLessons > 0 && Double(totalCompleted) / Double(totalLessons) >= 0.5
            case "Grand Master":
                shouldUnlock = completedStages == totalStages

            case "Dedicated":
                shouldUnlock = streak >= 3
            case "Week Warrior":
                shouldUnlock = streak >= 7
            case "Streak Legend":
                shouldUnlock = streak >= 30

            case "Code Starter":
                shouldUnlock = learningPath.stages.first(where: { $0.title == "Programming Basics" })?.state == .completed
            case "Version Pro":
                shouldUnlock = learningPath.stages.first(where: { $0.title == "Git & Version Control" })?.state == .completed
            case "UI Artisan":
                shouldUnlock = learningPath.stages.first(where: { $0.title == "Learn React" })?.state == .completed
            case "Data Wizard":
                shouldUnlock = learningPath.stages.first(where: { $0.title == "Backend Architecture" })?.state == .completed
            case "Architect":
                shouldUnlock = learningPath.stages.first(where: { $0.title == "Publish your App" })?.state == .completed

            case "Speed Learner":
                shouldUnlock = totalCompleted >= 8

            default:
                break
            }

            if shouldUnlock {
                achievements[i] = Achievement(
                    id: achievements[i].id,
                    title: achievements[i].title,
                    description: achievements[i].description,
                    iconName: achievements[i].iconName,
                    state: .earned,
                    earnedDate: Date(),
                    category: achievements[i].category
                )
                newlyUnlocked.append(achievements[i])
            }
        }

        return newlyUnlocked
    }

    // MARK: - Streak

    private func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastActive = calendar.startOfDay(for: userProgress.lastActiveDate)

        if lastActive == today { return }

        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        if lastActive == yesterday {
            userProgress.currentStreak += 1
        } else if lastActive < yesterday {
            userProgress.currentStreak = 1
        }

        userProgress.longestStreak = max(userProgress.longestStreak, userProgress.currentStreak)
        userProgress.lastActiveDate = Date()
    }

    // MARK: - Helpers

    private func findLesson(id: UUID) -> (Int, Int)? {
        for (si, stage) in learningPath.stages.enumerated() {
            for (li, lesson) in stage.lessons.enumerated() {
                if lesson.id == id { return (si, li) }
            }
        }
        return nil
    }

    func canAccessStage(_ stage: Stage) -> Bool {
        stage.state == .completed || stage.state == .current
    }

    func dismissMilestone() {
        showMilestoneAlert = false
        milestoneMessage = ""
    }

    func clearRecentCompletion() {
        recentlyCompletedLesson = nil
    }

    func clearRecentUnlocks() {
        recentlyUnlockedAchievements = []
    }

    func updateUserName(_ name: String) {
        userProgress.userName = name
        persist()
    }

    // MARK: - Clear All Data

    /// Clears all learning progress data from disk.
    /// This is automatically called when the app is deleted, but can also be called manually.
    func clearAllData() {
        LearningProgressPersistence.clearAll()
    }

    // MARK: - Persistence

    private func persist() {
        LearningProgressPersistence.save(
            learningPath: learningPath,
            userProgress: userProgress,
            achievements: achievements
        )
    }
}
