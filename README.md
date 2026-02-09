# Learning Progress App

A native iOS learning progress application built with SwiftUI, demonstrating modern iOS development patterns including MVVM architecture, reactive state management, and protocol-based dependency injection.

## Setup Instructions

### Requirements
- Xcode 15.0 or later
- iOS 17.0+ deployment target
- macOS Ventura or later

### Getting Started
1. Clone or download this repository
2. Open `task.xcodeproj` in Xcode
3. Select a simulator (iPhone 15 Pro recommended) or a physical device
4. Press `Cmd + R` to build and run

### Running Tests
- Press `Cmd + U` to run the full test suite
- Tests are located in the `taskTests` target

### Custom Fonts
The app uses the **Aeonik** font family. Font files are included in the project and registered via `Info.plist`.

---

## Architecture

### MVVM + Centralised Store

```
┌──────────────────────────────────────────────────────┐
│                    SwiftUI Views                     │
│  DashboardView · LearningPathView · AchievementView │
└─────────────────────┬────────────────────────────────┘
                      │ reads / actions
┌─────────────────────▼────────────────────────────────┐
│                    ViewModels                         │
│  DashboardVM · LearningPathVM · AchievementVM        │
│  (@Observable, computed props delegate to store)      │
└─────────────────────┬────────────────────────────────┘
                      │ reads / writes
┌─────────────────────▼────────────────────────────────┐
│              LearningStore (@Observable)              │
│  Single source of truth for all learning data        │
│  Handles: lesson completion, stage progression,      │
│  achievement unlocking, streak tracking              │
└──────────────────────────────────────────────────────┘
```

### Key Design Decisions

1. **`LearningStore`** — A single `@Observable` class holds all mutable state (`LearningPath`, `UserProgress`, `[Achievement]`). Because all ViewModels reference the same store instance, mutations propagate reactively across the entire app without manual synchronisation.

2. **`@Observable` ViewModels** — Each ViewModel exposes computed properties that delegate to the store. This means when the store changes (e.g., a lesson is completed on the Dashboard), the Learning Path and Achievement screens update automatically.

3. **`DependencyContainer`** — An `@Observable` container injected through SwiftUI's `Environment`. It provides the shared store and factory methods for ViewModels, enabling clean separation and testability.

4. **`LearningServiceProtocol`** — A protocol defining the data access contract. The `MockLearningService` implementation simulates network delays. This demonstrates protocol-based DI and can be swapped for a real API client.

5. **`AppRouter`** — An `@Observable` class managing tab selection and per-tab `NavigationPath` instances. Tapping the same tab resets its navigation stack.

### Navigation Flow

```
Dashboard
  ├── "For today" card → LessonDetailView → (complete lesson) → dismiss
  ├── "View full path" → switches to Learning Path tab
  └── "View all" badges → switches to Achievements tab

Learning Path
  ├── Completed stage tap → AchievementSheetView (celebration + share)
  ├── Current stage tap → StageDetailView → LessonDetailView
  └── Locked stage → disabled (no action)

Achievements
  ├── Earned badge tap → CelebrationOverlay (animation + share)
  └── Category filter → filters badge grid
```

---

## Features

### Dashboard Screen
- **Dynamic time-based greeting** — Changes message based on hour of day (morning/afternoon/evening/night)
- **"For today" lesson card** — Tappable, navigates to lesson detail; advances to next lesson after completion
- **Active learning path summary** — Shows current stage, progress bar, and "View full path" button
- **Achievement badges row** — Displays earned badges with "View all" navigation
- **Streak tracking** — Shows consecutive daily learning streak with flame icon
- **Milestone alerts** — Celebration overlay when completing a stage

### Learning Path Screen
- **Serpentine (zigzag) layout** — Two-column grid with alternating row directions
- **Arc connectors** — Smooth cubic bezier curves drawn badge-to-badge via `Canvas` + `PreferenceKey`
- **Three badge states** — Completed (purple with laurel), Current (blue with progress ring), Locked (gray with outline)
- **Stage progression** — Completing all lessons in a stage automatically unlocks the next
- **Tap interactions** — Completed → achievement sheet; Current → stage detail; Locked → disabled

### Achievement System
- **Automatic unlocking** — Achievements unlock when milestones are reached (lesson count, stage completion, streak length)
- **Achievement sheet** — Full-screen celebration with starburst rays, badge flip animation, confetti
- **Badge flip** — 3D Y-axis rotation reveals stage stats on the back
- **Social sharing** — "Share your achievement" button presents native iOS share sheet
- **Category filtering** — Filter by Milestone, Streak, Mastery, Special

### Lesson Completion Flow
1. Tap "For today" card or navigate to a lesson from stage detail
2. View lesson overview and key takeaways
3. Tap "Mark as Complete" button
4. Celebration animation plays (animated checkmark)
5. Store updates: lesson marked done → progress increments → stage/achievement checks run
6. All screens update reactively (Dashboard, Learning Path, Achievements)

---

## State Management

The app uses SwiftUI's `@Observable` macro (Observation framework, iOS 17+) for reactive state management:

| Component | Pattern | Purpose |
|---|---|---|
| `LearningStore` | `@Observable` | Single source of truth for all learning data |
| `DashboardViewModel` | `@Observable` | Dashboard-specific UI state + store delegation |
| `LearningPathViewModel` | `@Observable` | Path-specific UI state + store delegation |
| `AchievementViewModel` | `@Observable` | Achievement-specific UI state + store delegation |
| `AppRouter` | `@Observable` | Tab and navigation state management |
| `DependencyContainer` | `@Observable` + Environment | IoC container with factory methods |

---

## Testing Approach

The test suite covers four areas:

### 1. Model Tests (`ModelTests.swift`)
- Value computation (progress fractions, formatted strings)
- Mock data integrity validation
- Edge cases (empty collections, boundary values)

### 2. LearningStore Tests (`LearningStoreTests.swift`)
- Lesson completion flow
- Stage progression (current → completed → next unlocked)
- Achievement unlocking conditions
- Streak tracking (consecutive days vs. missed days)
- Duplicate completion prevention
- Access control (locked vs. accessible stages)

### 3. ViewModel Tests
- **Dashboard** — Greeting logic, reactive data, lesson completion side-effects
- **Learning Path** — Progress calculations, stage access rules, metadata
- **Achievement** — Category filtering, celebration flow, share text generation

### 4. Integration Patterns
- Tests create `LearningStore` instances with default or custom mock data
- ViewModels are tested through their store interactions
- No network mocking needed — store is the source of truth

---

## Project Structure

```
task/
├── taskApp.swift              # App entry point
├── ContentView.swift           # TabView root
├── Info.plist                  # Font registration
├── DI/
│   └── DependencyContainer.swift
├── Services/
│   ├── LearningService.swift   # Protocol + mock implementation
│   └── LearningStore.swift     # Central mutable store
├── Navigation/
│   └── AppRouter.swift         # Tab + NavigationPath management
├── Models/
│   ├── LearningModels.swift    # Core data structures
│   └── MockData.swift          # Static mock data
├── ViewModels/
│   ├── DashboardViewModel.swift
│   ├── LearningPathViewModel.swift
│   └── AchievementViewModel.swift
├── DesignSystem/
│   ├── AppTheme.swift          # Colors, fonts, spacing, gradients
│   └── Components/
│       ├── BadgeIconView.swift
│       └── ProgressBarView.swift
└── Views/
    ├── Dashboard/
    │   ├── DashboardView.swift
    │   ├── GreetingHeaderView.swift
    │   ├── TodayLessonCard.swift
    │   ├── LearningPathSummaryCard.swift
    │   ├── AchievementBadgesRow.swift
    │   └── StreakIndicatorView.swift
    ├── LearningPath/
    │   ├── LearningPathView.swift
    │   ├── StageItemView.swift      # Serpentine grid + connectors
    │   ├── StageDetailView.swift    # Stage lessons list
    │   └── LessonDetailView.swift   # Lesson content + completion
    └── Achievement/
        ├── AchievementView.swift
        ├── AchievementSheetView.swift
        ├── BadgeDetailView.swift
        └── CelebrationOverlay.swift
```

---

## Design System

- **Font**: Aeonik (Light, Regular, Medium, Bold + Italic variants)
- **Primary Color**: Indigo `#4B3F8F`
- **Background**: `#F5F5FA`
- **Spacing**: 4-point grid system (4, 8, 12, 16, 20, 24, 32, 40)
- **Corner Radius**: 8, 12, 16, 20pt scale
- **Shadows**: Subtle elevation with `0.06` black opacity

---

## Technical Highlights

- **iOS 17+ Observation framework** for zero-boilerplate reactivity
- **`Canvas` + `PreferenceKey`** for pixel-perfect serpentine arc connectors
- **Cubic bezier curves** approximating semicircular U-turns between badges
- **3D rotation effect** for badge flip animation
- **`UIActivityViewController` bridge** for native sharing
- **`UnevenRoundedRectangle`** for asymmetric card corners
- **Staggered spring animations** for celebration entrance sequences
