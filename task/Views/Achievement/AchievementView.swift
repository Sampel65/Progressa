//
//  AchievementView.swift
//  task
//
//  Created by Samson Oluwapelumi on 08/02/2026.
//

import SwiftUI

struct AchievementView: View {
    @Environment(\.dependencies) private var dependencies
    @State private var viewModel: AchievementViewModel?
    @Bindable var router: AppRouter

    var body: some View {
        NavigationStack(path: $router.achievementNavigationPath) {
            Group {
                if let vm = viewModel {
                    achievementContent(vm: vm)
                } else {
                    loadingView
                }
            }
            .background(AppColors.backgroundPrimary)
            .navigationBarHidden(true)
        }
        .task {
            if viewModel == nil {
                let vm = dependencies.makeAchievementViewModel()
                viewModel = vm
                await vm.loadAchievements()
            }
        }
    }

    // MARK: - Main Content

    @ViewBuilder
    private func achievementContent(vm: AchievementViewModel) -> some View {
        ZStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    awardsHeader(vm: vm)

                    VStack(spacing: 24) {
                        statsRow(vm: vm)
                            .padding(.top, -28)

                        categoryFilter(vm: vm)

                        let earned = vm.filteredAchievements.filter(\.isEarned)
                        if !earned.isEmpty {
                            earnedSection(achievements: earned, vm: vm)
                        }

                        let locked = vm.filteredAchievements.filter { !$0.isEarned }
                        if !locked.isEmpty {
                            lockedSection(achievements: locked, vm: vm)
                        }

                        Spacer(minLength: 48)
                    }
                    .padding(.horizontal, 16)
                }
            }
            .ignoresSafeArea(edges: .top)
            .refreshable {
                await viewModel?.loadAchievements()
            }

            if vm.showCelebration, let achievement = vm.celebratingAchievement {
                CelebrationOverlay(
                    achievement: achievement,
                    onDismiss: { vm.dismissCelebration() },
                    onShare: {
                        vm.prepareShare(for: achievement)
                    }
                )
            }
        }
        .sheet(isPresented: Binding(
            get: { viewModel?.showShareSheet ?? false },
            set: { viewModel?.showShareSheet = $0 }
        )) {
            if let text = viewModel?.shareText, !text.isEmpty {
                ShareSheetView(activityItems: [text])
                    .presentationDetents([.medium])
            }
        }
    }

    // MARK: - Awards Header

    @ViewBuilder
    private func awardsHeader(vm: AchievementViewModel) -> some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [
                    AppColors.primaryDark,
                    AppColors.primaryIndigo,
                    AppColors.primaryLight.opacity(0.9)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 260)
            .ignoresSafeArea(edges: .top)
            .overlay(
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.04))
                        .frame(width: 200, height: 200)
                        .offset(x: -120, y: -40)

                    Circle()
                        .fill(Color.white.opacity(0.03))
                        .frame(width: 160, height: 160)
                        .offset(x: 130, y: 30)
                }
            )
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: 28,
                    bottomTrailingRadius: 28,
                    topTrailingRadius: 0
                )
            )

            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(String(localized: "Awards"))
                            .font(AppFont.bold(28))
                            .foregroundStyle(.white)

                        Text(String(localized: "Your learning journey milestones"))
                            .font(AppFont.regular(14))
                            .foregroundStyle(.white.opacity(0.7))
                    }

                    Spacer()

                    ZStack {
                        CircularProgressView(
                            progress: vm.progressFraction,
                            lineWidth: 5,
                            size: 64,
                            backgroundColor: Color.white.opacity(0.15),
                            foregroundGradient: AngularGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "FFD700"),
                                    Color(hex: "FFB347"),
                                    Color(hex: "FFD700")
                                ]),
                                center: .center,
                                startAngle: .degrees(-90),
                                endAngle: .degrees(270)
                            )
                        )

                        VStack(spacing: -2) {
                            Text("\(vm.earnedCount)")
                                .font(AppFont.bold(20))
                                .foregroundStyle(.white)
                            Text("/\(vm.totalCount)")
                                .font(AppFont.regular(11))
                                .foregroundStyle(.white.opacity(0.6))
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)

                HStack(spacing: 8) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Color(hex: "FFD700"))

                    Text(headerMotivation(earned: vm.earnedCount, total: vm.totalCount))
                        .font(AppFont.medium(13))
                        .foregroundStyle(.white.opacity(0.85))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 44)
            }
        }
    }

    private func headerMotivation(earned: Int, total: Int) -> String {
        let pct = total > 0 ? Double(earned) / Double(total) : 0
        switch pct {
        case 0: return String(localized: "Start learning to earn your first badge!")
        case ..<0.25: return String(localized: "You're just getting started — keep it up!")
        case ..<0.5: return String(localized: "Great progress! Almost halfway there.")
        case ..<0.75: return String(localized: "Over halfway! Your collection is growing.")
        case ..<1.0: return String(localized: "So close to collecting them all!")
        default: return String(localized: "You've earned every badge. Legend!")
        }
    }

    // MARK: - Stats Row

    @ViewBuilder
    private func statsRow(vm: AchievementViewModel) -> some View {
        HStack(spacing: 12) {
            statCard(
                icon: "checkmark.circle.fill",
                value: "\(vm.completedStagesCount)",
                label: String(localized: "Stages"),
                color: AppColors.successGreen
            )

            statCard(
                icon: "book.closed.fill",
                value: "\(vm.lessonsCompleted)",
                label: String(localized: "Lessons"),
                color: AppColors.primaryLight
            )

            statCard(
                icon: "flame.fill",
                value: "\(vm.currentStreak)",
                label: String(localized: "Day Streak"),
                color: AppColors.streakFlame
            )
        }
    }

    private func statCard(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(color)

            Text(value)
                .font(AppFont.bold(22))
                .foregroundStyle(AppColors.textPrimary)

            Text(label)
                .font(AppFont.regular(11))
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.06), radius: 10, y: 4)
        )
    }

    // MARK: - Category Filter

    @ViewBuilder
    private func categoryFilter(vm: AchievementViewModel) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                filterChip(
                    title: String(localized: "All"),
                    icon: "square.grid.2x2.fill",
                    isSelected: vm.selectedCategory == nil,
                    action: { vm.selectCategory(nil) }
                )

                ForEach(vm.categories, id: \.self) { category in
                    filterChip(
                        title: category.localizedTitle,
                        icon: vm.iconForCategory(category),
                        isSelected: vm.selectedCategory == category,
                        action: { vm.selectCategory(category) }
                    )
                }
            }
        }
    }

    private func filterChip(title: String, icon: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .semibold))

                Text(title)
                    .font(AppFont.medium(13))
            }
            .foregroundStyle(isSelected ? .white : AppColors.textPrimary)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(
                Capsule()
                    .fill(isSelected ? AppColors.primaryIndigo : Color.white)
                    .shadow(color: isSelected ? AppColors.primaryIndigo.opacity(0.3) : .black.opacity(0.04), radius: isSelected ? 6 : 3, y: 2)
            )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func earnedSection(achievements: [Achievement], vm: AchievementViewModel) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Text(String(localized: "Earned"))
                    .font(AppFont.bold(20))
                    .foregroundStyle(AppColors.textPrimary)

                Text(L10n.badgeCount(achievements.count))
                    .font(AppFont.regular(13))
                    .foregroundStyle(AppColors.textSecondary)

                Spacer()
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(achievements) { achievement in
                        EarnedBadgeCard(
                            achievement: achievement,
                            onTap: { vm.triggerCelebration(for: achievement) }
                        )
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func lockedSection(achievements: [Achievement], vm: AchievementViewModel) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Text(String(localized: "Keep Going"))
                    .font(AppFont.bold(20))
                    .foregroundStyle(AppColors.textPrimary)

                Text("\(achievements.count) \(String(localized: "remaining"))")
                    .font(AppFont.regular(13))
                    .foregroundStyle(AppColors.textSecondary)

                Spacer()
            }

            LazyVStack(spacing: 12) {
                ForEach(achievements) { achievement in
                    LockedBadgeRow(
                        achievement: achievement,
                        hintText: unlockHint(for: achievement)
                    )
                }
            }
        }
    }

    private func unlockHint(for achievement: Achievement) -> String {
        switch achievement.category {
        case .mastery:
            let desc = achievement.description.replacingOccurrences(of: "Complete ", with: "")
            return String(format: String(localized: "Complete the \"%1$@\" to earn this"), desc)
        case .streak:
            return String(localized: "Keep your daily streak going")
        case .milestone:
            return String(localized: "Continue making progress on your learning path")
        case .special:
            return String(localized: "Push yourself further to unlock this reward")
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .controlSize(.large)
                .tint(AppColors.primaryIndigo)
            Text(String(localized: "Loading awards..."))
                .font(AppFont.regular(15))
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// ═══════════════════════════════════════════════════════
// MARK: - Earned Badge Card (Horizontal Carousel)
// ═══════════════════════════════════════════════════════

private struct EarnedBadgeCard: View {
    let achievement: Achievement
    let onTap: () -> Void

    @State private var shimmer = false

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Badge circle with starburst decoration
                ZStack {
                    // 8-ray starburst behind badge
                    BadgeStarburstView(
                        fillColor: colorForCategory(achievement.category).opacity(0.3),
                        strokeColor: colorForCategory(achievement.category).opacity(0.15)
                    )
                    .frame(width: 100, height: 100)

                    // Gradient border ring
                    Circle()
                        .strokeBorder(
                            AngularGradient(
                                colors: [
                                    colorForCategory(achievement.category),
                                    colorForCategory(achievement.category).opacity(0.4),
                                    colorForCategory(achievement.category)
                                ],
                                center: .center
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 68, height: 68)

                    // Icon circle
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    colorForCategory(achievement.category),
                                    colorForCategory(achievement.category).opacity(0.7)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: achievement.iconName)
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundStyle(.white)
                        )
                }

                // Title
                Text(achievement.title)
                    .font(AppFont.bold(14))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(1)

                // Category tag
                Text(achievement.category.localizedTitle)
                    .font(AppFont.medium(10))
                    .foregroundStyle(colorForCategory(achievement.category))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(colorForCategory(achievement.category).opacity(0.1))
                    )

                // Earned date
                if let date = achievement.earnedDate {
                    HStack(spacing: 3) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 9))
                            .foregroundStyle(AppColors.successGreen)

                        Text(date.formatted(.dateTime.month(.abbreviated).day()))
                            .font(AppFont.regular(10))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
            }
            .padding(.vertical, 18)
            .padding(.horizontal, 16)
            .frame(width: 150)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(
                        colorForCategory(achievement.category).opacity(0.12),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private func colorForCategory(_ category: AchievementCategory) -> Color {
        switch category {
        case .milestone: return AppColors.primaryIndigo
        case .streak: return AppColors.streakFlame
        case .mastery: return AppColors.accentOrange
        case .special: return AppColors.accentCoral
        }
    }
}

// ═══════════════════════════════════════════════════════
// MARK: - Locked Badge Row (Vertical List)
// ═══════════════════════════════════════════════════════

private struct LockedBadgeRow: View {
    let achievement: Achievement
    let hintText: String

    var body: some View {
        HStack(spacing: 14) {
            // Lock icon badge
            ZStack {
                Circle()
                    .fill(Color(hex: "F2F2F7"))
                    .frame(width: 54, height: 54)

                Image(systemName: achievement.iconName)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(AppColors.badgeLocked.opacity(0.6))

                // Lock overlay
                Circle()
                    .fill(Color.white.opacity(0.5))
                    .frame(width: 54, height: 54)

                Image(systemName: "lock.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(AppColors.textSecondary)
                    .offset(x: 16, y: 16)
            }

            // Text content
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(AppFont.medium(15))
                    .foregroundStyle(AppColors.textPrimary)

                Text(achievement.description)
                    .font(AppFont.regular(12))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(1)

                // Hint
                HStack(spacing: 4) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 9))
                        .foregroundStyle(AppColors.accentAmber)

                    Text(hintText)
                        .font(AppFont.regular(11))
                        .foregroundStyle(AppColors.textSecondary.opacity(0.8))
                        .lineLimit(1)
                }
            }

            Spacer()

            // Category indicator
            categoryDot(achievement.category)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.03), radius: 6, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(AppColors.badgeLocked.opacity(0.1), lineWidth: 1)
        )
    }

    @ViewBuilder
    private func categoryDot(_ category: AchievementCategory) -> some View {
        Circle()
            .fill(colorForCategory(category).opacity(0.2))
            .frame(width: 8, height: 8)
            .overlay(
                Circle()
                    .fill(colorForCategory(category))
                    .frame(width: 4, height: 4)
            )
    }

    private func colorForCategory(_ category: AchievementCategory) -> Color {
        switch category {
        case .milestone: return AppColors.primaryIndigo
        case .streak: return AppColors.streakFlame
        case .mastery: return AppColors.accentOrange
        case .special: return AppColors.accentCoral
        }
    }
}
