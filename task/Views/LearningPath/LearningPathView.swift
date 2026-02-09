//
//  LearningPathView.swift
//  task
//
//  Created by Samson Oluwapelumi on 07/02/2026.
//


import SwiftUI

struct LearningPathView: View {
    @Environment(\.dependencies) private var dependencies
    @State private var viewModel: LearningPathViewModel?
    @Bindable var router: AppRouter

    @State private var selectedCompletedStage: Stage?

    var body: some View {
        NavigationStack(path: $router.learningPathNavigationPath) {
            Group {
                if let vm = viewModel {
                    pathContent(vm: vm)
                } else {
                    loadingView
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(for: LearningPathDestination.self) { dest in
                switch dest {
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
                case .lessonDetail(let lesson):
                    LessonDetailView(lesson: lesson, store: dependencies.store)
                }
            }
        }
        .task {
            if viewModel == nil {
                let vm = dependencies.makeLearningPathViewModel()
                viewModel = vm
                await vm.loadLearningPath()
            }
        }
        .fullScreenCover(item: $selectedCompletedStage) { stage in
            AchievementSheetView(stage: stage) {
                selectedCompletedStage = nil
            }
            .presentationBackground(.clear)
        }
    }


    @ViewBuilder
    private func pathContent(vm: LearningPathViewModel) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                pathHeader(vm: vm)

                SerpentineStageGrid(
                    stages: vm.stages,
                    onCompletedStageTap: { stage in
                        selectedCompletedStage = stage
                    },
                    onCurrentStageTap: { stage in
                        router.learningPathNavigationPath.append(
                            LearningPathDestination.stageDetail(stage)
                        )
                    }
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
        }
        .background(Color(hex: "F5F5FA"))
        .ignoresSafeArea(edges: .top)
        .refreshable {
            await viewModel?.loadLearningPath()
        }
    }


    @ViewBuilder
    private func pathHeader(vm: LearningPathViewModel) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Button {
                router.selectedTab = .dashboard
            } label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(AppColors.textPrimary)
            }
            .padding(.bottom, 10)

            Text("Stage \(vm.currentStageNumber) of \(vm.totalStagesCount)")
                .font(AppFont.regular(14))
                .foregroundStyle(AppColors.textSecondary)

            Text(vm.pathTitle.capitalized(with: nil))
                .font(AppFont.bold(28))
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 60)
        .padding(.bottom, 36)
    }

    private var loadingView: some View {
        VStack(spacing: AppSpacing.md) {
            ProgressView()
                .controlSize(.large)
                .tint(AppColors.primaryIndigo)
            Text("Loading learning path...")
                .font(AppTypography.callout)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
