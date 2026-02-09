//
//  DashboardView.swift
//  task
//
//  Created by Samson Oluwapelumi on 08/02/2026.
//

import SwiftUI

struct DashboardView: View {
    @Environment(\.dependencies) private var dependencies
    @State private var viewModel: DashboardViewModel?
    @Bindable var router: AppRouter

    private let cardOverlap: CGFloat = 50

    var body: some View {
        NavigationStack(path: $router.dashboardNavigationPath) {
            Group {
                if let vm = viewModel {
                    dashboardContent(vm: vm)
                } else {
                    loadingView
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(for: DashboardDestination.self) { dest in
                switch dest {
                case .lessonDetail(let lesson):
                    LessonDetailView(lesson: lesson, store: dependencies.store)
                case .stageDetail(let stage):
                    StageDetailView(stage: stage, store: dependencies.store)
                        .navigationDestination(for: LearningPathDestination.self) { innerDest in
                            switch innerDest {
                            case .lessonDetail(let lesson):
                                LessonDetailView(lesson: lesson, store: dependencies.store)
                            case .stageDetail(let stage):
                                StageDetailView(stage: stage, store: dependencies.store)
                            }
                        }
                }
            }
        }
        .task {
            if viewModel == nil {
                let vm = dependencies.makeDashboardViewModel()
                viewModel = vm
                await vm.loadDashboard()
            }
        }
    }

    // MARK: - Dashboard Content

    @ViewBuilder
    private func dashboardContent(vm: DashboardViewModel) -> some View {
        ZStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    GreetingHeaderView(
                        greeting: vm.greeting,
                        userName: vm.userName,
                        motivationalMessage: vm.motivationalMessage,
                        currentStreak: vm.userProgress.currentStreak,
                        userInitials: String(vm.userName.prefix(2)).uppercased(),
                        onSignOut: { dependencies.authStore.signOut() },
                        bottomOverflow: cardOverlap + 10
                    )

                    VStack(spacing: AppSpacing.xl) {
                        if let todayLesson = vm.todayLesson {
                            TodayLessonCard(
                                todayLesson: todayLesson,
                                onTap: {
                                    router.dashboardNavigationPath.append(
                                        DashboardDestination.lessonDetail(todayLesson.lesson)
                                    )
                                }
                            )
                        }

                        // Active Learning Path
                        if let path = vm.learningPath as LearningPath?,
                           let stage = vm.currentStage {
                            LearningPathSummaryCard(
                                learningPath: path,
                                currentStage: stage,
                                onViewPath: {
                                    router.navigateToLearningPath()
                                }
                            )
                        }

                        // Badges
                        AchievementBadgesRow(
                            badges: MockData.dashboardBadges,
                            onViewAll: {
                                router.navigateToAchievements()
                            }
                        )

                        Spacer(minLength: 60)
                    }
                    .padding(.horizontal, 16)
                    .offset(y: -cardOverlap)
                    .padding(.bottom, -cardOverlap)
                }
            }
            .background(Color(hex: "F5F5FA"))
            .ignoresSafeArea(edges: .top)
            .refreshable {
                await viewModel?.loadDashboard()
            }

            if let vm = viewModel, vm.store.showMilestoneAlert {
                milestoneOverlay(message: vm.store.milestoneMessage, store: vm.store)
            }
        }
    }

    // MARK: - Milestone Alert

    @ViewBuilder
    private func milestoneOverlay(message: String, store: LearningStore) -> some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { store.dismissMilestone() }

            VStack(spacing: 20) {
                Image(systemName: "party.popper.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(AppColors.badgeEarned)

                Text(message)
                    .font(AppFont.bold(20))
                    .foregroundStyle(AppColors.textPrimary)
                    .multilineTextAlignment(.center)

                Button {
                    store.dismissMilestone()
                } label: {
                    Text("Continue")
                        .font(AppFont.bold(16))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(AppColors.primaryLight)
                        )
                }
            }
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
            )
            .padding(.horizontal, 40)
            .transition(.scale.combined(with: .opacity))
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: store.showMilestoneAlert)
    }

    // MARK: - Loading

    private var loadingView: some View {
        VStack(spacing: AppSpacing.md) {
            ProgressView()
                .controlSize(.large)
                .tint(AppColors.primaryIndigo)
            Text("Loading your dashboard...")
                .font(AppTypography.callout)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "F5F5FA"))
    }
}
