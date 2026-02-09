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
        title: "Fullstack mobile engineer path",
        description: "Master fullstack mobile development from fundamentals to deployment",
        stages: [
            // Stage 1 - Current (first stage for new user)
            Stage(
                id: UUID(),
                title: "Programming Basics",
                description: "Learn the foundation of programming",
                state: .current,
                lessons: [
                    Lesson(id: UUID(), title: "Introduction to Programming", subtitle: "Core concepts", durationMinutes: 15, isCompleted: false, iconName: "doc.text"),
                    Lesson(id: UUID(), title: "Variables & Data Types", subtitle: "Primitives and structures", durationMinutes: 20, isCompleted: false, iconName: "textformat"),
                    Lesson(id: UUID(), title: "Control Flow", subtitle: "Loops and conditionals", durationMinutes: 25, isCompleted: false, iconName: "arrow.triangle.branch"),
                ],
                badgeIconName: "globe",
                stageNumber: 1
            ),
            // Stage 2 - Locked
            Stage(
                id: UUID(),
                title: "Git & Version Control",
                description: "Master version control workflows",
                state: .locked,
                lessons: [
                    Lesson(id: UUID(), title: "Git Basics", subtitle: "Init, add, commit", durationMinutes: 20, isCompleted: false, iconName: "arrow.triangle.branch"),
                    Lesson(id: UUID(), title: "Branching & Merging", subtitle: "Collaboration patterns", durationMinutes: 25, isCompleted: false, iconName: "arrow.triangle.merge"),
                    Lesson(id: UUID(), title: "GitHub Workflows", subtitle: "Pull requests and reviews", durationMinutes: 20, isCompleted: false, iconName: "person.2"),
                ],
                badgeIconName: "bolt.fill",
                stageNumber: 2
            ),
            // Stage 3 - Locked
            Stage(
                id: UUID(),
                title: "Learn React",
                description: "Component lifecycle",
                state: .locked,
                lessons: [
                    Lesson(id: UUID(), title: "React Components", subtitle: "Component lifecycle", durationMinutes: 25, isCompleted: false, iconName: "square.stack.3d.up"),
                    Lesson(id: UUID(), title: "State & Props", subtitle: "Component lifecycle", durationMinutes: 30, isCompleted: false, iconName: "arrow.triangle.2.circlepath"),
                    Lesson(id: UUID(), title: "Build a login screen in React", subtitle: "Component lifecycle", durationMinutes: 25, isCompleted: false, iconName: "person.crop.rectangle"),
                    Lesson(id: UUID(), title: "React Hooks", subtitle: "Component lifecycle", durationMinutes: 30, isCompleted: false, iconName: "link"),
                ],
                badgeIconName: "atom",
                stageNumber: 3
            ),
            // Stage 4 - Locked
            Stage(
                id: UUID(),
                title: "Core Mobile UI Build",
                description: "Build cross-platform mobile interfaces",
                state: .locked,
                lessons: [
                    Lesson(id: UUID(), title: "Mobile UI Fundamentals", subtitle: "Layout and styling", durationMinutes: 20, isCompleted: false, iconName: "iphone"),
                    Lesson(id: UUID(), title: "Core Components", subtitle: "View, Text, Image", durationMinutes: 25, isCompleted: false, iconName: "rectangle.3.group"),
                    Lesson(id: UUID(), title: "Responsive Layouts", subtitle: "Adaptive design patterns", durationMinutes: 25, isCompleted: false, iconName: "rectangle.split.3x1"),
                ],
                badgeIconName: "iphone",
                stageNumber: 4
            ),
            // Stage 5 - Locked
            Stage(
                id: UUID(),
                title: "Access Device Features",
                description: "Camera, location, and sensors",
                state: .locked,
                lessons: [
                    Lesson(id: UUID(), title: "Camera & Photos", subtitle: "Media capture APIs", durationMinutes: 25, isCompleted: false, iconName: "camera"),
                    Lesson(id: UUID(), title: "Location Services", subtitle: "GPS and geofencing", durationMinutes: 30, isCompleted: false, iconName: "location"),
                ],
                badgeIconName: "sensor.tag.radiowaves.forward",
                stageNumber: 5
            ),
            // Stage 6 - Locked
            Stage(
                id: UUID(),
                title: "Navigations and Forms",
                description: "App navigation and user input",
                state: .locked,
                lessons: [
                    Lesson(id: UUID(), title: "Navigation Patterns", subtitle: "Stack, tab, and drawer", durationMinutes: 25, isCompleted: false, iconName: "arrow.right.arrow.left"),
                    Lesson(id: UUID(), title: "Forms & Validation", subtitle: "Input handling", durationMinutes: 30, isCompleted: false, iconName: "doc.plaintext"),
                ],
                badgeIconName: "arrow.right.arrow.left",
                stageNumber: 6
            ),
            // Stage 7 - Locked
            Stage(
                id: UUID(),
                title: "Backend Architecture",
                description: "Server-side design patterns",
                state: .locked,
                lessons: [
                    Lesson(id: UUID(), title: "REST API Design", subtitle: "Endpoints and resources", durationMinutes: 25, isCompleted: false, iconName: "server.rack"),
                    Lesson(id: UUID(), title: "Database Modeling", subtitle: "Schema design", durationMinutes: 25, isCompleted: false, iconName: "cylinder"),
                ],
                badgeIconName: "server.rack",
                stageNumber: 7
            ),
            // Stage 8 - Locked
            Stage(
                id: UUID(),
                title: "Node.js & Express",
                description: "Server-side JavaScript",
                state: .locked,
                lessons: [
                    Lesson(id: UUID(), title: "Express.js Basics", subtitle: "REST API creation", durationMinutes: 25, isCompleted: false, iconName: "network"),
                    Lesson(id: UUID(), title: "Middleware & Routing", subtitle: "Request pipeline", durationMinutes: 30, isCompleted: false, iconName: "point.3.connected.trianglepath.dotted"),
                ],
                badgeIconName: "network.badge.shield.half.filled",
                stageNumber: 8
            ),
            // Stage 9 - Locked
            Stage(
                id: UUID(),
                title: "Authentication & Authorization",
                description: "Security and access control",
                state: .locked,
                lessons: [
                    Lesson(id: UUID(), title: "JWT & OAuth", subtitle: "Token-based auth", durationMinutes: 25, isCompleted: false, iconName: "lock.shield"),
                    Lesson(id: UUID(), title: "Role-Based Access", subtitle: "Permissions system", durationMinutes: 30, isCompleted: false, iconName: "person.badge.key"),
                ],
                badgeIconName: "lock.shield.fill",
                stageNumber: 9
            ),
            // Stage 10 - Locked
            Stage(
                id: UUID(),
                title: "Write and Run Tests",
                description: "Unit and integration testing",
                state: .locked,
                lessons: [
                    Lesson(id: UUID(), title: "Unit Testing", subtitle: "Jest and testing library", durationMinutes: 25, isCompleted: false, iconName: "checkmark.shield"),
                    Lesson(id: UUID(), title: "E2E Testing", subtitle: "End-to-end with Detox", durationMinutes: 25, isCompleted: false, iconName: "checklist"),
                ],
                badgeIconName: "checkmark.seal.fill",
                stageNumber: 10
            ),
            // Stage 11 - Locked
            Stage(
                id: UUID(),
                title: "Publish your App",
                description: "App Store deployment",
                state: .locked,
                lessons: [
                    Lesson(id: UUID(), title: "App Store Submission", subtitle: "Review guidelines", durationMinutes: 30, isCompleted: false, iconName: "app.badge"),
                    Lesson(id: UUID(), title: "CI/CD Pipeline", subtitle: "Automated deployment", durationMinutes: 25, isCompleted: false, iconName: "gearshape.2"),
                    Lesson(id: UUID(), title: "Portfolio & Launch", subtitle: "Presentation and feedback", durationMinutes: 30, isCompleted: false, iconName: "trophy.fill"),
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
            id: UUID(), title: "Code Starter",
            description: "Complete Programming Basics",
            iconName: "chevron.left.forwardslash.chevron.right",
            state: .locked,
            earnedDate: nil,
            category: .mastery
        ),
        Achievement(
            id: UUID(), title: "Version Pro",
            description: "Complete Git & Version Control",
            iconName: "arrow.triangle.branch",
            state: .locked,
            earnedDate: nil,
            category: .mastery
        ),
        Achievement(
            id: UUID(), title: "First Steps",
            description: "Complete your first lesson",
            iconName: "figure.walk",
            state: .locked,
            earnedDate: nil,
            category: .milestone
        ),
        Achievement(
            id: UUID(), title: "Dedicated",
            description: "Maintain a 3-day learning streak",
            iconName: "flame.fill",
            state: .locked,
            earnedDate: nil,
            category: .streak
        ),
        Achievement(
            id: UUID(), title: "UI Artisan",
            description: "Complete the React stage",
            iconName: "paintbrush.fill",
            state: .locked,
            earnedDate: nil,
            category: .mastery
        ),
        Achievement(
            id: UUID(), title: "Week Warrior",
            description: "Maintain a 7-day learning streak",
            iconName: "bolt.fill",
            state: .locked,
            earnedDate: nil,
            category: .streak
        ),
        Achievement(
            id: UUID(), title: "Halfway Hero",
            description: "Complete 50% of all lessons",
            iconName: "flag.fill",
            state: .locked,
            earnedDate: nil,
            category: .milestone
        ),
        Achievement(
            id: UUID(), title: "Data Wizard",
            description: "Complete the Backend Architecture stage",
            iconName: "server.rack",
            state: .locked,
            earnedDate: nil,
            category: .mastery
        ),
        Achievement(
            id: UUID(), title: "Speed Learner",
            description: "Complete 8 lessons total",
            iconName: "hare.fill",
            state: .locked,
            earnedDate: nil,
            category: .special
        ),
        Achievement(
            id: UUID(), title: "Streak Legend",
            description: "Maintain a 30-day learning streak",
            iconName: "flame.circle.fill",
            state: .locked,
            earnedDate: nil,
            category: .streak
        ),
        Achievement(
            id: UUID(), title: "Architect",
            description: "Complete Publish your App",
            iconName: "building.columns.fill",
            state: .locked,
            earnedDate: nil,
            category: .mastery
        ),
        Achievement(
            id: UUID(), title: "Grand Master",
            description: "Complete the entire learning path",
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
