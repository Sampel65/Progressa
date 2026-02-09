//
//  MockData.swift
//  task
//
//  Created by Samson Oluwapelumi on 08/02/2026.
//

import Foundation

// MARK: - Mock Data Provider

enum MockData {

    // MARK: - User Progress

    static let userProgress = UserProgress(
        currentStreak: 1,
        longestStreak: 1,
        totalLessonsCompleted: 0,
        totalLessons: 28,
        achievementsEarned: 0,
        totalAchievements: 12,
        lastActiveDate: Date(),
        userName: "Learner"
    )

    // MARK: - Learning Path

    static let learningPath = LearningPath(
        id: UUID(),
        title: String(localized: "Fullstack mobile engineer path"),
        description: String(localized: "Master fullstack mobile development from fundamentals to deployment"),
        stages: [
            // Stage 1 - Current (first stage for new user)
            Stage(
                id: UUID(),
                title: String(localized: "Programming Basics"),
                description: String(localized: "Learn the foundation of programming"),
                state: .current,
                lessons: [
                    Lesson(id: UUID(), title: String(localized: "Introduction to Programming"), subtitle: String(localized: "Core concepts"), durationMinutes: 15, isCompleted: false, iconName: "doc.text"),
                    Lesson(id: UUID(), title: String(localized: "Variables & Data Types"), subtitle: String(localized: "Primitives and structures"), durationMinutes: 20, isCompleted: false, iconName: "textformat"),
                    Lesson(id: UUID(), title: String(localized: "Control Flow"), subtitle: String(localized: "Loops and conditionals"), durationMinutes: 25, isCompleted: false, iconName: "arrow.triangle.branch"),
                ],
                badgeIconName: "globe",
                stageNumber: 1
            ),
            // Stage 2 - Locked
            Stage(
                id: UUID(),
                title: String(localized: "Git & Version Control"),
                description: String(localized: "Master version control workflows"),
                state: .locked,
                lessons: [
                    Lesson(id: UUID(), title: String(localized: "Git Basics"), subtitle: String(localized: "Init, add, commit"), durationMinutes: 20, isCompleted: false, iconName: "arrow.triangle.branch"),
                    Lesson(id: UUID(), title: String(localized: "Branching & Merging"), subtitle: String(localized: "Collaboration patterns"), durationMinutes: 25, isCompleted: false, iconName: "arrow.triangle.merge"),
                    Lesson(id: UUID(), title: String(localized: "GitHub Workflows"), subtitle: String(localized: "Pull requests and reviews"), durationMinutes: 20, isCompleted: false, iconName: "person.2"),
                ],
                badgeIconName: "bolt.fill",
                stageNumber: 2
            ),
            // Stage 3 - Locked
            Stage(
                id: UUID(),
                title: String(localized: "Learn React"),
                description: String(localized: "Component lifecycle"),
                state: .locked,
                lessons: [
                    Lesson(id: UUID(), title: String(localized: "React Components"), subtitle: String(localized: "Component lifecycle"), durationMinutes: 25, isCompleted: false, iconName: "square.stack.3d.up"),
                    Lesson(id: UUID(), title: String(localized: "State & Props"), subtitle: String(localized: "Component lifecycle"), durationMinutes: 30, isCompleted: false, iconName: "arrow.triangle.2.circlepath"),
                    Lesson(id: UUID(), title: String(localized: "Build a login screen in React"), subtitle: String(localized: "Component lifecycle"), durationMinutes: 25, isCompleted: false, iconName: "person.crop.rectangle"),
                    Lesson(id: UUID(), title: String(localized: "React Hooks"), subtitle: String(localized: "Component lifecycle"), durationMinutes: 30, isCompleted: false, iconName: "link"),
                ],
                badgeIconName: "atom",
                stageNumber: 3
            ),
            // Stage 4 - Locked
            Stage(
                id: UUID(),
                title: String(localized: "Core Mobile UI Build"),
                description: String(localized: "Build cross-platform mobile interfaces"),
                state: .locked,
                lessons: [
                    Lesson(id: UUID(), title: String(localized: "Mobile UI Fundamentals"), subtitle: String(localized: "Layout and styling"), durationMinutes: 20, isCompleted: false, iconName: "iphone"),
                    Lesson(id: UUID(), title: String(localized: "Core Components"), subtitle: String(localized: "View, Text, Image"), durationMinutes: 25, isCompleted: false, iconName: "rectangle.3.group"),
                    Lesson(id: UUID(), title: String(localized: "Responsive Layouts"), subtitle: String(localized: "Adaptive design patterns"), durationMinutes: 25, isCompleted: false, iconName: "rectangle.split.3x1"),
                ],
                badgeIconName: "iphone",
                stageNumber: 4
            ),
            // Stage 5 - Locked
            Stage(
                id: UUID(),
                title: String(localized: "Access Device Features"),
                description: String(localized: "Camera, location, and sensors"),
                state: .locked,
                lessons: [
                    Lesson(id: UUID(), title: String(localized: "Camera & Photos"), subtitle: String(localized: "Media capture APIs"), durationMinutes: 25, isCompleted: false, iconName: "camera"),
                    Lesson(id: UUID(), title: String(localized: "Location Services"), subtitle: String(localized: "GPS and geofencing"), durationMinutes: 30, isCompleted: false, iconName: "location"),
                ],
                badgeIconName: "sensor.tag.radiowaves.forward",
                stageNumber: 5
            ),
            // Stage 6 - Locked
            Stage(
                id: UUID(),
                title: String(localized: "Navigations and Forms"),
                description: String(localized: "App navigation and user input"),
                state: .locked,
                lessons: [
                    Lesson(id: UUID(), title: String(localized: "Navigation Patterns"), subtitle: String(localized: "Stack, tab, and drawer"), durationMinutes: 25, isCompleted: false, iconName: "arrow.right.arrow.left"),
                    Lesson(id: UUID(), title: String(localized: "Forms & Validation"), subtitle: String(localized: "Input handling"), durationMinutes: 30, isCompleted: false, iconName: "doc.plaintext"),
                ],
                badgeIconName: "arrow.right.arrow.left",
                stageNumber: 6
            ),
            // Stage 7 - Locked
            Stage(
                id: UUID(),
                title: String(localized: "Backend Architecture"),
                description: String(localized: "Server-side design patterns"),
                state: .locked,
                lessons: [
                    Lesson(id: UUID(), title: String(localized: "REST API Design"), subtitle: String(localized: "Endpoints and resources"), durationMinutes: 25, isCompleted: false, iconName: "server.rack"),
                    Lesson(id: UUID(), title: String(localized: "Database Modeling"), subtitle: String(localized: "Schema design"), durationMinutes: 25, isCompleted: false, iconName: "cylinder"),
                ],
                badgeIconName: "server.rack",
                stageNumber: 7
            ),
            // Stage 8 - Locked
            Stage(
                id: UUID(),
                title: String(localized: "Node.js & Express"),
                description: String(localized: "Server-side JavaScript"),
                state: .locked,
                lessons: [
                    Lesson(id: UUID(), title: String(localized: "Express.js Basics"), subtitle: String(localized: "REST API creation"), durationMinutes: 25, isCompleted: false, iconName: "network"),
                    Lesson(id: UUID(), title: String(localized: "Middleware & Routing"), subtitle: String(localized: "Request pipeline"), durationMinutes: 30, isCompleted: false, iconName: "point.3.connected.trianglepath.dotted"),
                ],
                badgeIconName: "network.badge.shield.half.filled",
                stageNumber: 8
            ),
            // Stage 9 - Locked
            Stage(
                id: UUID(),
                title: String(localized: "Authentication & Authorization"),
                description: String(localized: "Security and access control"),
                state: .locked,
                lessons: [
                    Lesson(id: UUID(), title: String(localized: "JWT & OAuth"), subtitle: String(localized: "Token-based auth"), durationMinutes: 25, isCompleted: false, iconName: "lock.shield"),
                    Lesson(id: UUID(), title: String(localized: "Role-Based Access"), subtitle: String(localized: "Permissions system"), durationMinutes: 30, isCompleted: false, iconName: "person.badge.key"),
                ],
                badgeIconName: "lock.shield.fill",
                stageNumber: 9
            ),
            // Stage 10 - Locked
            Stage(
                id: UUID(),
                title: String(localized: "Write and Run Tests"),
                description: String(localized: "Unit and integration testing"),
                state: .locked,
                lessons: [
                    Lesson(id: UUID(), title: String(localized: "Unit Testing"), subtitle: String(localized: "Jest and testing library"), durationMinutes: 25, isCompleted: false, iconName: "checkmark.shield"),
                    Lesson(id: UUID(), title: String(localized: "E2E Testing"), subtitle: String(localized: "End-to-end with Detox"), durationMinutes: 25, isCompleted: false, iconName: "checklist"),
                ],
                badgeIconName: "checkmark.seal.fill",
                stageNumber: 10
            ),
            // Stage 11 - Locked
            Stage(
                id: UUID(),
                title: String(localized: "Publish your App"),
                description: String(localized: "App Store deployment"),
                state: .locked,
                lessons: [
                    Lesson(id: UUID(), title: String(localized: "App Store Submission"), subtitle: String(localized: "Review guidelines"), durationMinutes: 30, isCompleted: false, iconName: "app.badge"),
                    Lesson(id: UUID(), title: String(localized: "CI/CD Pipeline"), subtitle: String(localized: "Automated deployment"), durationMinutes: 25, isCompleted: false, iconName: "gearshape.2"),
                    Lesson(id: UUID(), title: String(localized: "Portfolio & Launch"), subtitle: String(localized: "Presentation and feedback"), durationMinutes: 30, isCompleted: false, iconName: "trophy.fill"),
                ],
                badgeIconName: "shippingbox.fill",
                stageNumber: 11
            ),
        ]
    )

    // MARK: - Achievements

    static let achievements: [Achievement] = [
        // ── All locked for fresh user — unlocked dynamically by LearningStore ──
        Achievement(
            id: UUID(), title: String(localized: "Code Starter"),
            description: String(localized: "Complete Programming Basics"),
            iconName: "chevron.left.forwardslash.chevron.right",
            state: .locked,
            earnedDate: nil,
            category: .mastery
        ),
        Achievement(
            id: UUID(), title: String(localized: "Version Pro"),
            description: String(localized: "Complete Git & Version Control"),
            iconName: "arrow.triangle.branch",
            state: .locked,
            earnedDate: nil,
            category: .mastery
        ),
        Achievement(
            id: UUID(), title: String(localized: "First Steps"),
            description: String(localized: "Complete your first lesson"),
            iconName: "figure.walk",
            state: .locked,
            earnedDate: nil,
            category: .milestone
        ),
        Achievement(
            id: UUID(), title: String(localized: "Dedicated"),
            description: String(localized: "Maintain a 3-day learning streak"),
            iconName: "flame.fill",
            state: .locked,
            earnedDate: nil,
            category: .streak
        ),
        Achievement(
            id: UUID(), title: String(localized: "UI Artisan"),
            description: String(localized: "Complete the React stage"),
            iconName: "paintbrush.fill",
            state: .locked,
            earnedDate: nil,
            category: .mastery
        ),
        Achievement(
            id: UUID(), title: String(localized: "Week Warrior"),
            description: String(localized: "Maintain a 7-day learning streak"),
            iconName: "bolt.fill",
            state: .locked,
            earnedDate: nil,
            category: .streak
        ),
        Achievement(
            id: UUID(), title: String(localized: "Halfway Hero"),
            description: String(localized: "Complete 50% of all lessons"),
            iconName: "flag.fill",
            state: .locked,
            earnedDate: nil,
            category: .milestone
        ),
        Achievement(
            id: UUID(), title: String(localized: "Data Wizard"),
            description: String(localized: "Complete the Backend Architecture stage"),
            iconName: "server.rack",
            state: .locked,
            earnedDate: nil,
            category: .mastery
        ),
        Achievement(
            id: UUID(), title: String(localized: "Speed Learner"),
            description: String(localized: "Complete 8 lessons total"),
            iconName: "hare.fill",
            state: .locked,
            earnedDate: nil,
            category: .special
        ),
        Achievement(
            id: UUID(), title: String(localized: "Streak Legend"),
            description: String(localized: "Maintain a 30-day learning streak"),
            iconName: "flame.circle.fill",
            state: .locked,
            earnedDate: nil,
            category: .streak
        ),
        Achievement(
            id: UUID(), title: String(localized: "Architect"),
            description: String(localized: "Complete Publish your App"),
            iconName: "building.columns.fill",
            state: .locked,
            earnedDate: nil,
            category: .mastery
        ),
        Achievement(
            id: UUID(), title: String(localized: "Grand Master"),
            description: String(localized: "Complete the entire learning path"),
            iconName: "trophy.fill",
            state: .locked,
            earnedDate: nil,
            category: .milestone
        ),
    ]

    // MARK: - Dashboard Badges (matching Figma design)

    struct DashboardBadge: Identifiable {
        let id = UUID()
        let title: String
        let subtitle: String
        let gemColor: BadgeGemColor
    }

    enum BadgeGemColor {
        case blue, orange, purple
    }

    static let dashboardBadges: [DashboardBadge] = [
        DashboardBadge(title: String(localized: "Mastery"), subtitle: String(localized: "Complete stages"), gemColor: .blue),
        DashboardBadge(title: String(localized: "Streak"), subtitle: String(localized: "Stay consistent"), gemColor: .orange),
        DashboardBadge(title: String(localized: "Milestone"), subtitle: String(localized: "Hit key goals"), gemColor: .purple),
    ]

    // MARK: - Today's Lesson

    static var todayLesson: TodayLesson {
        let currentStage = learningPath.stages.first(where: { $0.state == .current })!
        let nextLesson = currentStage.lessons.first(where: { !$0.isCompleted })!
        let lessonIndex = currentStage.lessons.firstIndex(where: { $0.id == nextLesson.id })! + 1

        return TodayLesson(
            id: UUID(),
            lesson: nextLesson,
            stageName: currentStage.title,
            stageNumber: currentStage.stageNumber,
            lessonIndex: lessonIndex,
            totalLessonsInStage: currentStage.lessons.count
        )
    }
}
