//
//  LearningStore.swift
//  task
//
//  Created by Samson Oluwapelumi on 07/02/2026.
//


import Foundation

/// Centralized store for all learning-related state and business logic.
/// Acts as the single source of truth for learning progress, achievements, and user data.
/// All mutations flow through this store, ensuring consistent state across the app.
@Observable
final class LearningStore {

    /// The complete learning path with all stages and lessons.
    /// Mutations are private to ensure all updates go through controlled methods.
    private(set) var learningPath: LearningPath
    
    /// Aggregated user progress metrics including streak, completion counts, and dates.
    private(set) var userProgress: UserProgress
    
    /// All available achievements with their current unlock state.
    private(set) var achievements: [Achievement]

    /// Temporary state for UI feedback after lesson completion.
    /// Set when a lesson is completed and cleared by the view after displaying.
    var recentlyCompletedLesson: Lesson?
    
    /// Achievements that were unlocked during the last lesson completion.
    /// Used to trigger celebration animations in the UI.
    var recentlyUnlockedAchievements: [Achievement] = []
    
    /// Flag to show milestone alert when a stage is completed.
    var showMilestoneAlert = false
    
    /// Message to display in the milestone alert.
    var milestoneMessage = ""


    /// Initializes the store, attempting to load persisted data first.
    /// Falls back to mock data if no saved progress exists (first launch).
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


    /// Computes the next lesson to display on the dashboard's "For Today" card.
    /// Returns the first incomplete lesson in the current stage, or nil if all stages are complete.
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


    /// Marks a lesson as completed and triggers all related state updates.
    /// This is the primary mutation method for lesson completion and orchestrates:
    /// - Lesson status update
    /// - Stage completion check and next stage unlock
    /// - Achievement unlocking
    /// - Streak calculation
    /// - Progress metrics update
    /// - Data persistence
    ///
    /// - Parameter lessonId: The unique identifier of the lesson to complete
    /// - Returns: `true` if the lesson was successfully completed, `false` if not found or already completed
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


    /// Checks if a stage is complete and handles progression logic.
    /// When all lessons in the current stage are completed:
    /// - Marks the stage as completed
    /// - Unlocks the next stage (if available)
    /// - Triggers milestone alert for UI feedback
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


    /// Evaluates all locked achievements against current progress and unlocks those that meet criteria.
    /// Achievement types checked:
    /// - Milestone: First lesson, halfway point, all stages complete
    /// - Streak: 3, 7, and 30 day streaks
    /// - Mastery: Completion of specific stages
    /// - Special: Custom criteria like completing 8 lessons
    ///
    /// - Returns: Array of newly unlocked achievements for celebration display
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


    /// Updates the learning streak based on the last active date.
    /// Streak logic:
    /// - If last active was yesterday: increment streak
    /// - If last active was before yesterday: reset streak to 1
    /// - If already active today: no change
    /// Also updates the longest streak record if current exceeds it.
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


    func clearAllData() {
        LearningProgressPersistence.clearAll()
    }


    private func persist() {
        LearningProgressPersistence.save(
            learningPath: learningPath,
            userProgress: userProgress,
            achievements: achievements
        )
    }
}
