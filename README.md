# Learning Progress App

A native iOS learning progress application built with SwiftUI, demonstrating modern iOS development patterns including MVVM architecture, reactive state management, protocol-based dependency injection, and secure authentication.

## 📱 Overview

**Learning Progress** is a comprehensive learning management application that helps users track their educational journey through structured learning paths. The app features:

- **Personalized Dashboard** with time-based greetings and daily lesson recommendations
- **Interactive Learning Paths** with a visually stunning serpentine (zigzag) stage layout
- **Achievement System** with automatic badge unlocking and celebration animations
- **Progress Tracking** with streak counters and milestone celebrations
- **Secure Authentication** with Keychain-based credential storage
- **Persistent State** that survives app restarts
- **Full Internationalization** with support for English, Spanish, and French

---
APP DEMO 

<img width="642" height="1389" alt="IMG_1953" src="https://github.com/user-attachments/assets/5e24d6c3-7f73-40f7-ba4f-0a2a79588f85" />
<img width="642" height="1389" alt="Screenshot 2026-02-09 at 09 44 57" src="https://github.com/user-attachments/assets/2b619a4d-3871-4442-9195-7aef9cff9fdc" />
<img width="642" height="1389" alt="Screenshot 2026-02-09 at 09 45 24" src="https://github.com/user-attachments/assets/01a3aedc-f1d7-47c0-b944-3054522f2df4" />
<img width="642" height="1389" alt="Screenshot 2026-02-09 at 09 50 10" src="https://github.com/user-attachments/assets/80a438df-e752-443f-a3dc-b62e4555f4b8" />

App English Demo : https://drive.google.com/file/d/1jbXdsXFECYH6NjOh9oB0Z7OXPbUlLz7e/view?usp=drive_link


https://github.com/user-attachments/assets/504d195c-0083-4cc2-ba24-4704166022ab



## 🚀 Getting Started

### Requirements

- **Xcode 15.0** or later
- **iOS 17.0+** deployment target
- **macOS Ventura** or later (for development)
- **Swift 5.9+**

### Installation

1. Clone or download this repository
2. Open `task.xcodeproj` in Xcode
3. Select a simulator (iPhone 15 Pro recommended) or a physical device
4. Press `Cmd + R` to build and run

### Running Tests

- Press `Cmd + U` to run the full test suite
- Tests are located in the `taskTests` target
- Test coverage includes models, store logic, and view models

### Custom Fonts

The app uses the **Aeonik** font family. Font files are included in the project and registered via `Info.plist`. The following variants are available:

- Aeonik-Light
- Aeonik-Regular
- Aeonik-Medium
- Aeonik-Bold
- Aeonik-RegularItalic
- Aeonik-BoldItalic
- Aeonik-MediumItalic
- Aeonik-ThinItalic

---

## 🏗️ Architecture

### MVVM + Centralized Store Pattern

```
┌──────────────────────────────────────────────────────┐
│                    SwiftUI Views                     │
│  DashboardView · LearningPathView · AchievementView │
│  AuthContainerView · WelcomeView · LoginView         │
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
└─────────────────────┬────────────────────────────────┘
                      │ persists
┌─────────────────────▼────────────────────────────────┐
│         LearningProgressPersistence                    │
│  JSON-based local persistence                        │
└──────────────────────────────────────────────────────┘
```

### Key Design Decisions

1. **`LearningStore`** — A single `@Observable` class holds all mutable state (`LearningPath`, `UserProgress`, `[Achievement]`). Because all ViewModels reference the same store instance, mutations propagate reactively across the entire app without manual synchronisation.

2. **`@Observable` ViewModels** — Each ViewModel exposes computed properties that delegate to the store. This means when the store changes (e.g., a lesson is completed on the Dashboard), the Learning Path and Achievement screens update automatically.

3. **`DependencyContainer`** — An `@Observable` container injected through SwiftUI's `Environment`. It provides the shared store and factory methods for ViewModels, enabling clean separation and testability.

4. **`LearningServiceProtocol`** — A protocol defining the data access contract. The `MockLearningService` implementation simulates network delays. This demonstrates protocol-based DI and can be swapped for a real API client.

5. **`AppRouter`** — An `@Observable` class managing tab selection and per-tab `NavigationPath` instances. Tapping the same tab resets its navigation stack.

6. **`AuthStore`** — Manages authentication state and credential storage via iOS Keychain. Supports sign up, sign in, and session restoration.

---

## 🧭 Navigation Flow

```
Welcome Screen
  ├── "Get Started" → SignupView
  └── "Sign In" → LoginView

SignupView / LoginView
  └── Success → Main App (TabView)

Main App (TabView)
  ├── Dashboard Tab
  │   ├── "For today" card → LessonDetailView → (complete lesson) → dismiss
  │   ├── "View full path" → switches to Learning Path tab
  │   └── "View all" badges → switches to Achievements tab
  │
  ├── Learning Path Tab
  │   ├── Completed stage tap → AchievementSheetView (celebration + share)
  │   ├── Current stage tap → StageDetailView → LessonDetailView
  │   └── Locked stage → disabled (no action)
  │
  └── Achievements Tab
      ├── Earned badge tap → CelebrationOverlay (animation + share)
      └── Category filter → filters badge grid
```

---

## ✨ Features

### Authentication System

- **Welcome Screen** with animated Lottie illustrations and gradient backgrounds
- **Sign Up Flow** with validation:
  - Name must be at least 2 characters
  - Email format validation
  - Password must be at least 8 characters
  - Password confirmation matching
  - Duplicate account detection
- **Sign In Flow** with credential verification
- **Session Persistence** via iOS Keychain
- **Automatic Session Restoration** on app launch
- **Sign Out** functionality with state cleanup

### Dashboard Screen

- **Dynamic Time-Based Greeting** — Changes message based on hour of day:
  - Morning (5 AM - 12 PM): "Good morning"
  - Afternoon (12 PM - 5 PM): "Good afternoon"
  - Evening (5 PM - 9 PM): "Good evening"
  - Night (9 PM - 5 AM): "Good night"
- **Personalized Motivational Messages** based on progress and streak
- **"For Today" Lesson Card** — Tappable, navigates to lesson detail; advances to next lesson after completion
- **Active Learning Path Summary** — Shows current stage, progress bar, and "View full path" button
- **Achievement Badges Row** — Displays earned badges with "View all" navigation
- **Streak Tracking** — Shows consecutive daily learning streak with flame icon
- **Milestone Alerts** — Celebration overlay when completing a stage
- **Pull-to-Refresh** support

### Learning Path Screen

- **Serpentine (Zigzag) Layout** — Two-column grid with alternating row directions
- **Arc Connectors** — Smooth cubic bezier curves drawn badge-to-badge via `Canvas` + `PreferenceKey`
- **Three Badge States**:
  - **Completed** (purple badge with laurel) — Shows achievement sheet on tap
  - **Current** (blue badge with animated progress ring) — Navigates to stage detail
  - **Locked** (gray badge with outline) — Disabled interaction
- **Stage Progression** — Completing all lessons in a stage automatically unlocks the next
- **Tap Interactions**:
  - Completed → Achievement sheet with celebration
  - Current → Stage detail view
  - Locked → No action
- **Progress Visualization** — Animated circular progress indicators for current stages

### Achievement System

- **Automatic Unlocking** — Achievements unlock when milestones are reached:
  - **Milestone Achievements**: First Steps, Halfway Hero, Grand Master
  - **Streak Achievements**: Dedicated (3 days), Week Warrior (7 days), Streak Legend (30 days)
  - **Mastery Achievements**: Code Starter, Version Pro, UI Artisan, Data Wizard, Architect
  - **Special Achievements**: Speed Learner
- **Achievement Sheet** — Full-screen celebration with:
  - Starburst rays animation
  - Badge flip animation (3D Y-axis rotation)
  - Stage statistics on badge back
  - Confetti effects
- **Social Sharing** — "Share your achievement" button presents native iOS share sheet
- **Category Filtering** — Filter by Milestone, Streak, Mastery, Special
- **Achievement Grid** — Responsive layout showing earned and locked badges
- **Progress Tracking** — Header shows completion statistics

### Lesson Completion Flow

1. Tap "For today" card or navigate to a lesson from stage detail
2. View lesson overview with title, subtitle, duration, and key takeaways
3. Tap "Mark as Complete" button
4. Celebration animation plays (animated checkmark via Lottie)
5. Store updates:
   - Lesson marked as completed
   - Progress increments
   - Stage completion checks run
   - Achievement checks run
   - Streak updates
6. All screens update reactively (Dashboard, Learning Path, Achievements)
7. Milestone alerts shown for stage completions

### Progress Persistence

- **Local JSON Storage** — Learning progress saved to `Application Support/Progressa/learning_progress.json`
- **Automatic Persistence** — State saved after every lesson completion
- **Session Restoration** — Progress restored on app launch
- **Secure Credential Storage** — User credentials stored in iOS Keychain

### Internationalization & Localization

- **Multi-Language Support** — Full support for English, Spanish, and French
- **String Catalogs** — Modern `.xcstrings` format for easy translation management
- **Automatic Language Detection** — App adapts to device language settings
- **Pluralization Handling** — Proper singular/plural forms for all languages
- **Type-Safe Localization** — L10n helper functions for formatted strings
- **Comprehensive Coverage** — All user-facing strings are localized including:
  - UI labels and buttons
  - Error messages
  - Achievement descriptions
  - Motivational messages
  - Navigation titles
- **Easy Translation** — Add new languages via Xcode's String Catalog editor
- **Format String Support** — Parameterized strings with proper argument ordering

---

## 🎨 Design System

### Typography

- **Font Family**: Aeonik
- **Font Weights**: Light, Regular, Medium, Bold
- **Font Styles**: Regular, Italic
- **Semantic Tokens**:
  - Callout: Medium 15pt
  - Footnote: Regular 13pt
  - Caption Small: Regular 11pt

### Colors

- **Primary**:
  - Indigo: `#4B3F8F`
  - Light: `#6C5FBC`
  - Dark: `#8636E8`
- **Accent**:
  - Orange: `#FF8C42`
  - Amber: `#FFB347`
  - Coral: `#FF6B6B`
- **Success**:
  - Green: `#34C759`
  - Light: `#A8E6CF`
- **Background**:
  - Primary: `#F5F5FA`
  - Card: White
- **Text**:
  - Primary: `#1A1A2E`
  - Secondary: `#8E8E93`
- **Special**:
  - Streak Flame: `#FF6B35`
  - Badge Earned: `#FFD700`
  - Badge Locked: `#C7C7CC`

### Spacing

4-point grid system:
- `xxs`: 4pt
- `xs`: 8pt
- `sm`: 12pt
- `md`: 16pt
- `xl`: 24pt

### Corner Radius

- Small: 8pt
- Large: 16pt

### Shadows

- Subtle elevation with `0.06` black opacity
- Default radius: 8pt
- Default Y offset: 4pt

### Gradients

- **Primary**: Indigo to Light Purple
- **Accent**: Orange to Amber
- **Success**: Green to Light Green
- **Streak**: Flame Orange gradient

---

## 📦 Dependencies

### External Packages

- **DotLottie iOS** (`dotlottie-ios`) v0.12.1
  - Used for Lottie animation rendering
  - Provides `DotLottieAnimation` component
  - Supports `.json` and `.lottie` file formats

### System Frameworks

- **SwiftUI** — UI framework
- **Foundation** — Core functionality
- **Security** — Keychain access
- **Combine** — Reactive programming (via SwiftUI)

---

## 🧪 Testing Approach

The test suite covers four main areas:

### 1. Model Tests (`ModelTests.swift`)

- Value computation (progress fractions, formatted strings)
- Mock data integrity validation
- Edge cases (empty collections, boundary values)
- Equatable and Hashable conformance

### 2. LearningStore Tests (`LearningStoreTests.swift`)

- Lesson completion flow
- Stage progression (current → completed → next unlocked)
- Achievement unlocking conditions
- Streak tracking (consecutive days vs. missed days)
- Duplicate completion prevention
- Access control (locked vs. accessible stages)
- Persistence integration

### 3. ViewModel Tests

- **DashboardViewModelTests**:
  - Greeting logic (time-based messages)
  - Reactive data updates
  - Lesson completion side-effects
  - Motivational message generation
  
- **LearningPathViewModelTests**:
  - Progress calculations
  - Stage access rules
  - Metadata computation
  
- **AchievementViewModelTests**:
  - Category filtering
  - Celebration flow
  - Share text generation
  - Progress statistics

### 4. Integration Patterns

- Tests create `LearningStore` instances with default or custom mock data
- ViewModels are tested through their store interactions
- No network mocking needed — store is the source of truth
- Dependency injection enables easy test doubles

---

## 📁 Project Structure

```
task/
├── taskApp.swift                    # App entry point
├── ContentView.swift                 # Root view with auth routing
├── Info.plist                        # Font registration
│
├── DI/
│   └── DependencyContainer.swift     # IoC container + Environment key
│
├── Services/
│   ├── LearningService.swift         # Protocol + mock implementation
│   ├── LearningStore.swift          # Central mutable store
│   ├── AuthStore.swift               # Authentication state manager
│   ├── KeychainHelper.swift          # Secure credential storage
│   └── LearningProgressPersistence.swift  # JSON persistence
│
├── Navigation/
│   └── AppRouter.swift               # Tab + NavigationPath management
│
├── Models/
│   ├── LearningModels.swift         # Core data structures
│   └── MockData.swift                # Static mock data
│
├── ViewModels/
│   ├── DashboardViewModel.swift      # Dashboard business logic
│   ├── LearningPathViewModel.swift   # Learning path logic
│   └── AchievementViewModel.swift    # Achievement logic
│
├── DesignSystem/
│   ├── AppTheme.swift                # Colors, fonts, spacing, gradients
│   ├── L10n.swift                    # Localization helpers
│   └── Components/
│       ├── LottieView.swift          # Lottie animation wrapper
│       └── ProgressBarView.swift     # Reusable progress bar
│
├── Views/
│   ├── Auth/
│   │   ├── AuthContainerView.swift   # Auth flow coordinator
│   │   ├── WelcomeView.swift         # Welcome screen with animations
│   │   ├── LoginView.swift           # Sign in form
│   │   └── SignupView.swift          # Sign up form
│   │
│   ├── Dashboard/
│   │   ├── DashboardView.swift      # Main dashboard screen
│   │   ├── GreetingHeaderView.swift  # Personalized header
│   │   ├── TodayLessonCard.swift     # Today's lesson card
│   │   ├── LearningPathSummaryCard.swift  # Path progress summary
│   │   ├── AchievementBadgesRow.swift    # Badge preview row
│   │   └── StreakIndicatorView.swift     # Streak counter
│   │
│   ├── LearningPath/
│   │   ├── LearningPathView.swift   # Path overview screen
│   │   ├── StageItemView.swift       # Serpentine grid + connectors
│   │   ├── StageDetailView.swift     # Stage lessons list
│   │   └── LessonDetailView.swift    # Lesson content + completion
│   │
│   └── Achievement/
│       ├── AchievementView.swift     # Achievement grid screen
│       ├── AchievementSheetView.swift # Full-screen celebration
│       ├── BadgeDetailView.swift     # Badge detail modal
│       └── CelebrationOverlay.swift   # Celebration animations
│
├── Animations/                       # Lottie JSON files
│   ├── loading_dots.json
│   ├── success_checkmark.json
│   ├── welcome.json
│   ├── welcome2.json
│   └── welcome_learning.json
│
├── Assets.xcassets/                  # Image assets
│   ├── AppIcon.appiconset/
│   ├── badge_*.imageset/
│   ├── arrow_right.imageset/
│   ├── flame.imageset/
│   ├── messages.imageset/
│   ├── notification.imageset/
│   └── ...
│
└── Resources/
    └── Localizable.xcstrings         # Localization strings
```

---

## 🔧 Technical Highlights

### State Management

- **iOS 17+ Observation Framework** — Zero-boilerplate reactivity using `@Observable` macro
- **Single Source of Truth** — `LearningStore` centralizes all mutable state
- **Reactive Updates** — Changes propagate automatically across all views
- **Computed Properties** — ViewModels expose derived state from store

### UI/UX Features

- **Canvas + PreferenceKey** — Pixel-perfect serpentine arc connectors between badges
- **Cubic Bezier Curves** — Smooth semicircular U-turns approximating badge connections
- **3D Rotation Effects** — Badge flip animation with Y-axis rotation
- **Staggered Spring Animations** — Celebration entrance sequences
- **Lottie Animations** — Loading states, success checkmarks, welcome screens
- **Native Sharing** — `UIActivityViewController` bridge for social sharing
- **UnevenRoundedRectangle** — Asymmetric card corners for visual interest
- **Pull-to-Refresh** — Native refreshable support on scroll views

### Security

- **Keychain Storage** — Secure credential persistence using iOS Security framework
- **Accessible When Unlocked** — Keychain items only accessible when device is unlocked
- **Device-Only Storage** — Credentials don't sync across devices (can be extended)

### Persistence

- **JSON-Based Storage** — Human-readable progress files in Application Support
- **Automatic Saving** — Progress persisted after every lesson completion
- **Session Restoration** — State restored on app launch
- **Error Handling** — Graceful fallback to default state on load failure

### Localization

The app includes comprehensive internationalization (i18n) support using Apple's modern String Catalogs format.

#### Supported Languages

- **English (en)** — Source language, fully translated
- **Spanish (es)** — Fully translated
- **French (fr)** — Fully translated

#### Implementation

- **String Catalogs** — Modern `.xcstrings` format (iOS 15+) stored in `Resources/Localizable.xcstrings`
- **String(localized:)** — SwiftUI's built-in localization API used throughout the app
- **L10n Helper Functions** — Type-safe localization utilities in `DesignSystem/L10n.swift`
- **Pluralization Support** — Proper handling of singular/plural forms (e.g., "1 day" vs "2 days")
- **Format Strings** — Parameterized localization strings with proper argument ordering

#### Usage Examples

**Basic String Localization:**
```swift
Text(String(localized: "Welcome Back"))
Text(String(localized: "Sign In"))
```

**Format Strings with Parameters:**
```swift
// Stage counter: "Stage 3 of 11"
L10n.stageOfTotal(3, total: 11)

// Lesson progress: "5 of 10 lessons"
L10n.lessonsProgress(completed: 5, total: 10)
```

**Pluralization:**
```swift
// Automatically handles "1 day" vs "2 days"
L10n.streakDays(1)  // "1 day"
L10n.streakDays(5)  // "5 days"

// Badge count pluralization
L10n.badgeCount(1)  // "1 badge"
L10n.badgeCount(3)  // "3 badges"
```

**Localized Error Messages:**
```swift
enum AuthError: LocalizedError {
    case invalidEmail
    var errorDescription: String? {
        String(localized: "Please enter a valid email address.")
    }
}
```

#### L10n Helper Functions

The `L10n` enum provides type-safe localization helpers:

- `stageOfTotal(_:total:)` — Formats stage counter with proper pluralization
- `lessonsProgress(completed:total:)` — Formats lesson progress string
- `streakDays(_:)` — Formats streak count with singular/plural handling
- `badgeCount(_:)` — Formats badge count with singular/plural handling

#### Adding New Languages

1. Open `Resources/Localizable.xcstrings` in Xcode
2. Click the "+" button to add a new language
3. Select the language from the list (e.g., German, Italian, etc.)
4. Xcode will automatically extract all localizable strings
5. Translate each string in the new language column
6. Build and run to test

#### String Catalog Format

The `.xcstrings` file uses JSON format with:
- **Source Language**: English (en)
- **Localizations**: Each string has translations for supported languages
- **State Tracking**: "new", "translated", "needs_review" states
- **String Units**: Contains the actual translated value

Example entry:
```json
"Welcome Back" : {
  "localizations" : {
    "en" : {
      "stringUnit" : {
        "state" : "translated",
        "value" : "Welcome Back"
      }
    },
    "es" : {
      "stringUnit" : {
        "state" : "translated",
        "value" : "Bienvenido de nuevo"
      }
    },
    "fr" : {
      "stringUnit" : {
        "state" : "translated",
        "value" : "Bon retour"
      }
    }
  }
}
```

#### Project Configuration

- **Development Region**: English (en)
- **Known Regions**: Base, en, es, fr
- **LOCALIZATION_PREFERS_STRING_CATALOGS**: YES
- **STRING_CATALOG_GENERATE_SYMBOLS**: YES
- **SWIFT_EMIT_LOC_STRINGS**: YES

#### Best Practices

1. **Always use `String(localized:)`** for user-facing strings
2. **Use L10n helpers** for formatted strings and pluralization
3. **Avoid hardcoded strings** in UI code
4. **Test with different languages** using iOS Simulator language settings
5. **Keep strings context-free** when possible for better reusability
6. **Use format specifiers** (`%lld`, `%@`) for dynamic content

---

## 🎯 Core Models

### Learning Models

- **`Lesson`** — Individual learning unit with title, subtitle, duration, completion status
- **`Stage`** — Collection of lessons with state (completed/current/locked), progress tracking
- **`LearningPath`** — Complete learning journey with multiple stages
- **`Achievement`** — Badge with category, earned state, and unlock date
- **`UserProgress`** — Aggregated progress metrics (streak, lessons completed, achievements)
- **`TodayLesson`** — Convenience wrapper for dashboard's "today" lesson

### Authentication Models

- **`UserProfile`** — User information (name, email, join date)
- **`AuthState`** — Authentication state enum (unknown/onboarding/authenticated)
- **`AuthError`** — Localized error types for authentication failures

### Navigation Models

- **`AppTab`** — Tab bar items (dashboard, learningPath, achievements)
- **`DashboardDestination`** — Navigation destinations for dashboard tab
- **`LearningPathDestination`** — Navigation destinations for learning path tab
- **`AchievementDestination`** — Navigation destinations for achievements tab

---

## 🔄 Data Flow

### Lesson Completion Flow

```
User taps "Mark as Complete"
    ↓
LessonDetailView calls store.completeLesson(lessonId)
    ↓
LearningStore updates:
    - Lesson.isCompleted = true
    - userProgress.totalLessonsCompleted += 1
    - Checks stage completion
    - Checks achievement unlocks
    - Updates streak
    - Persists to disk
    ↓
@Observable triggers view updates:
    - DashboardViewModel (reactive)
    - LearningPathViewModel (reactive)
    - AchievementViewModel (reactive)
    ↓
All views update automatically
```

### Authentication Flow

```
App Launch
    ↓
ContentView checks AuthStore.authState
    ↓
AuthStore.restoreSession() checks Keychain
    ↓
If credentials exist:
    → AuthState.authenticated(profile)
    → Show main app
Else:
    → AuthState.onboarding
    → Show WelcomeView
    ↓
User signs up/signs in
    ↓
AuthStore persists to Keychain
    ↓
AuthState.authenticated(profile)
    ↓
ContentView shows main app
```

---

## 🚧 Future Enhancements

### Potential Features

- **Cloud Sync** — Sync progress across devices via iCloud or backend API
- **Multiple Learning Paths** — Support for different course tracks
- **Social Features** — Share progress with friends, leaderboards
- **Offline Mode** — Enhanced offline support with sync queue
- **Push Notifications** — Daily reminders and achievement notifications
- **Dark Mode** — Full dark mode support with adaptive colors
- **Accessibility** — VoiceOver improvements, Dynamic Type support
- **iPad Support** — Optimized layouts for larger screens
- **Widgets** — Home screen widgets showing streak and progress
- **Analytics** — Learning analytics and insights dashboard

### Technical Improvements

- **Backend Integration** — Replace `MockLearningService` with real API client
- **Unit Test Coverage** — Increase test coverage to 90%+
- **UI Tests** — Add UI automation tests
- **Performance Optimization** — Profile and optimize rendering performance
- **Error Handling** — Enhanced error states and recovery flows
- **Caching Strategy** — Implement image and data caching
- **Migration System** — Handle data model version migrations

---

## 📝 Code Style & Conventions

### Naming Conventions

- **Views**: PascalCase with "View" suffix (e.g., `DashboardView`)
- **ViewModels**: PascalCase with "ViewModel" suffix (e.g., `DashboardViewModel`)
- **Models**: PascalCase (e.g., `LearningPath`, `UserProgress`)
- **Services**: PascalCase with descriptive names (e.g., `LearningStore`, `AuthStore`)
- **Functions**: camelCase with descriptive verbs (e.g., `completeLesson`, `loadDashboard`)
- **Properties**: camelCase (e.g., `todayLesson`, `userProgress`)

### File Organization

- One main type per file
- Related types grouped in same file with `// MARK:` separators
- Extensions in same file as main type when closely related
- Test files mirror source file structure

### Documentation

- Public APIs documented with doc comments
- Complex logic includes inline comments
- `// MARK:` used for logical section separation
- Architecture decisions documented in README

---

## 🐛 Known Issues & Limitations

### Current Limitations

- **Single Learning Path** — App supports one active learning path
- **No Cloud Sync** — Progress is device-local only
- **Mock Data Only** — No real backend integration
- **Limited Localization** — English primary, partial support for other languages
- **No Offline Queue** — Network operations fail silently in offline mode
- **No Data Migration** — App data model changes require fresh install

### Known Issues

- None currently documented

---

## 📄 License

This project is provided as-is for educational and demonstration purposes.

---

## 👤 Author

**Samson Oluwapelumi**

Created: February 8, 2026

---

## 🙏 Acknowledgments

- **Aeonik Font Family** — Custom typography
- **LottieFiles** — Animation library and resources
- **Apple** — SwiftUI and iOS frameworks

---

## 📚 Additional Resources

### SwiftUI Documentation
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [Observation Framework](https://developer.apple.com/documentation/observation)

### Design Resources
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines)
- [SF Symbols](https://developer.apple.com/sf-symbols/)

### Testing
- [Testing in Xcode](https://developer.apple.com/documentation/xctest)
- [Swift Testing](https://developer.apple.com/documentation/testing)

---

**Last Updated**: February 9, 2026
