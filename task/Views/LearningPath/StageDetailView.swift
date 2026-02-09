//
//  StageDetailView.swift
//  task
//
//  Created by Samson Oluwapelumi on 08/02/2026.
//

import SwiftUI

// ═══════════════════════════════════════════════════════
// MARK: - Stage Detail View
// ═══════════════════════════════════════════════════════

/// Shows all lessons in a stage with their completion states.
/// The user can tap any incomplete lesson to navigate to
/// `LessonDetailView` and complete it.
struct StageDetailView: View {
    let stage: Stage
    let store: LearningStore

    @Environment(\.dismiss) private var dismiss

    /// Live version of the stage (re-read from store for reactivity).
    private var liveStage: Stage {
        store.learningPath.stages.first(where: { $0.id == stage.id }) ?? stage
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                // Header
                stageHeader

                // Lessons list
                VStack(spacing: 12) {
                    ForEach(Array(liveStage.lessons.enumerated()), id: \.element.id) { index, lesson in
                        NavigationLink(value: LearningPathDestination.lessonDetail(lesson)) {
                            lessonRow(lesson, index: index + 1)
                        }
                        .buttonStyle(.plain)
                        .disabled(lesson.isCompleted)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
        }
        .background(Color(hex: "F5F5FA"))
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(AppColors.textPrimary)
                }
            }
        }
    }

    // MARK: - Header

    private var stageHeader: some View {
        VStack(spacing: 16) {
            // Badge icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "7B68EE"), Color(hex: "9B8FFF")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)

                Image(systemName: liveStage.badgeIconName)
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(.white)
            }

            // Title & description
            VStack(spacing: 6) {
                Text(liveStage.title)
                    .font(AppFont.bold(24))
                    .foregroundStyle(AppColors.textPrimary)

                Text(liveStage.description)
                    .font(AppFont.regular(15))
                    .foregroundStyle(AppColors.textSecondary)
            }
            .multilineTextAlignment(.center)

            // Progress
            HStack(spacing: 12) {
                ProgressBarView(
                    progress: liveStage.progressFraction,
                    height: 6,
                    foregroundGradient: AppGradients.primary
                )
                .frame(width: 120)

                Text("\(liveStage.completedLessonsCount) of \(liveStage.lessons.count) lessons")
                    .font(AppFont.medium(13))
                    .foregroundStyle(AppColors.textSecondary)
            }

            // State badge
            Text(liveStage.state == .completed ? "Completed" : "In Progress")
                .font(AppFont.medium(12))
                .foregroundStyle(liveStage.state == .completed ? AppColors.successGreen : AppColors.primaryIndigo)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(
                            liveStage.state == .completed
                            ? AppColors.successGreen.opacity(0.12)
                            : AppColors.primaryIndigo.opacity(0.1)
                        )
                )
        }
        .padding(.top, 16)
        .padding(.bottom, 28)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Lesson Row

    private func lessonRow(_ lesson: Lesson, index: Int) -> some View {
        HStack(spacing: 14) {
            // Completion indicator
            ZStack {
                Circle()
                    .fill(lesson.isCompleted ? AppColors.successGreen : Color(hex: "E8E0FF"))
                    .frame(width: 40, height: 40)

                if lesson.isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                } else {
                    Text("\(index)")
                        .font(AppFont.bold(15))
                        .foregroundStyle(AppColors.primaryIndigo)
                }
            }

            // Lesson info
            VStack(alignment: .leading, spacing: 4) {
                Text(lesson.title)
                    .font(AppFont.medium(15))
                    .foregroundStyle(
                        lesson.isCompleted ? AppColors.textSecondary : AppColors.textPrimary
                    )
                    .strikethrough(lesson.isCompleted, color: AppColors.textSecondary)
                    .lineLimit(2)

                HStack(spacing: 8) {
                    Label(lesson.formattedDuration, systemImage: "clock")
                        .font(AppFont.regular(12))
                        .foregroundStyle(AppColors.textSecondary)

                    Text("·")
                        .foregroundStyle(AppColors.textSecondary)

                    Text(lesson.subtitle)
                        .font(AppFont.regular(12))
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            // Arrow for incomplete lessons
            if !lesson.isCompleted {
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
        )
    }
}
