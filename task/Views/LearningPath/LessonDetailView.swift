//
//  LessonDetailView.swift
//  task
//
//  Created by Samson Oluwapelumi on 08/02/2026.
//

import SwiftUI
import DotLottie

// ═══════════════════════════════════════════════════════
// MARK: - Lesson Detail View
// ═══════════════════════════════════════════════════════

/// Displays lesson content and allows the user to mark it complete.
/// On completion, a celebration animation plays before dismissing.
struct LessonDetailView: View {
    let lesson: Lesson
    let store: LearningStore

    @Environment(\.dismiss) private var dismiss

    @State private var showCompleted = false
    @State private var confettiActive = false
    @State private var checkScale: CGFloat = 0
    @State private var contentOpacity: Double = 0

    /// Live version of the lesson from the store.
    private var isCompleted: Bool {
        store.learningPath.stages
            .flatMap(\.lessons)
            .first(where: { $0.id == lesson.id })?
            .isCompleted ?? lesson.isCompleted
    }

    /// Find which stage this lesson belongs to.
    private var parentStage: Stage? {
        store.learningPath.stages.first(where: { stage in
            stage.lessons.contains(where: { $0.id == lesson.id })
        })
    }

    var body: some View {
        ZStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    // Hero area
                    lessonHero

                    // Mock content
                    lessonContent

                    // Complete button
                    if !isCompleted && !showCompleted {
                        completeButton
                    }

                    Spacer(minLength: 80)
                }
                .padding(.horizontal, 20)
                .opacity(showCompleted ? 0.3 : 1)
            }
            .background(Color(hex: "F5F5FA"))

            // Completion celebration overlay
            if showCompleted {
                completionOverlay
            }
        }
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
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) {
                contentOpacity = 1
            }
        }
    }

    // MARK: - Hero

    private var lessonHero: some View {
        VStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "7B68EE"), Color(hex: "9B8FFF")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 72, height: 72)

                Image(systemName: lesson.iconName)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(.white)
            }

            // Title
            Text(lesson.title)
                .font(AppFont.bold(22))
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.center)

            // Subtitle
            Text(lesson.subtitle)
                .font(AppFont.regular(15))
                .foregroundStyle(AppColors.textSecondary)

            // Duration & stage
            HStack(spacing: 16) {
                Label(lesson.formattedDuration, systemImage: "clock")
                    .font(AppFont.medium(13))
                    .foregroundStyle(AppColors.primaryIndigo)

                if let stage = parentStage {
                    Label("Stage \(stage.stageNumber)", systemImage: "flag.fill")
                        .font(AppFont.medium(13))
                        .foregroundStyle(AppColors.primaryIndigo)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(
                Capsule()
                    .fill(AppColors.primaryIndigo.opacity(0.08))
            )

            // Already completed indicator
            if isCompleted && !showCompleted {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(AppColors.successGreen)
                    Text("Already completed")
                        .font(AppFont.medium(14))
                        .foregroundStyle(AppColors.successGreen)
                }
                .padding(.top, 4)
            }
        }
        .padding(.top, 20)
        .opacity(contentOpacity)
    }

    // MARK: - Mock Content

    private var lessonContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Lesson Overview")
                .font(AppFont.bold(18))
                .foregroundStyle(AppColors.textPrimary)

            Text(overviewText)
                .font(AppFont.regular(15))
                .foregroundStyle(AppColors.textSecondary)
                .lineSpacing(6)

            Divider()
                .padding(.vertical, 4)

            Text("Key Takeaways")
                .font(AppFont.bold(16))
                .foregroundStyle(AppColors.textPrimary)

            ForEach(keyTakeaways, id: \.self) { point in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(AppColors.primaryLight)
                        .padding(.top, 2)

                    Text(point)
                        .font(AppFont.regular(14))
                        .foregroundStyle(AppColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
        )
        .opacity(contentOpacity)
    }

    // MARK: - Complete Button

    private var completeButton: some View {
        Button {
            completeLesson()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 18, weight: .semibold))
                Text("Mark as Complete")
                    .font(AppFont.bold(16))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(AppColors.primaryLight)
            )
        }
        .opacity(contentOpacity)
    }

    // MARK: - Completion Overlay

    private var completionOverlay: some View {
        VStack(spacing: 24) {
            Spacer()

            // Lottie checkmark animation with SwiftUI fallback
            LottieOrFallback(name: "welcome", loop: false, speed: 1.0) {
                ZStack {
                    Circle()
                        .fill(AppColors.successGreen)
                        .frame(width: 100, height: 100)
                        .scaleEffect(checkScale)

                    Image(systemName: "checkmark")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundStyle(.white)
                        .scaleEffect(checkScale)
                }
            }
            .frame(width: 140, height: 140)

            Text("Lesson Complete!")
                .font(AppFont.bold(24))
                .foregroundStyle(AppColors.textPrimary)

            Text("Great work! Keep the momentum going.")
                .font(AppFont.regular(16))
                .foregroundStyle(AppColors.textSecondary)

            // Continue button
            Button {
                dismiss()
            } label: {
                Text("Continue")
                    .font(AppFont.bold(16))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(AppColors.primaryLight)
                    )
            }
            .padding(.horizontal, 40)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color(hex: "F5F5FA").opacity(0.95))
    }

    // MARK: - Actions

    private func completeLesson() {
        // 1. Complete in store (updates everywhere)
        store.completeLesson(lessonId: lesson.id)

        // 2. Show celebration
        showCompleted = true

        withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.1)) {
            checkScale = 1.0
        }
    }

    // MARK: - Mock Content Strings

    private var overviewText: String {
        "In this lesson you'll explore the core concepts of \(lesson.title). Through practical examples and hands-on exercises, you'll build a strong understanding of the fundamentals that underpin modern software development. By the end, you'll be able to apply these concepts confidently in real-world projects."
    }

    private var keyTakeaways: [String] {
        [
            "Understand the fundamental principles of \(lesson.subtitle)",
            "Apply techniques through practical coding exercises",
            "Build confidence with real-world scenario walkthroughs",
            "Prepare for the next lesson in the learning path",
        ]
    }
}
