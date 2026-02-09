//
//  LearningPathSummaryCard.swift
//  task
//
//  Created by Samson Oluwapelumi on 08/02/2026.
//


import SwiftUI

struct LearningPathSummaryCard: View {
    let learningPath: LearningPath
    let currentStage: Stage
    let onViewPath: () -> Void

    private var badgeImageName: String {
        switch currentStage.state {
        case .current, .completed: return "blue_badge"
        case .locked: return "Grey_badge"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text(String(localized: "Active learning path"))
                .font(AppFont.bold(18))
                .foregroundStyle(AppColors.textPrimary)

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(learningPath.title)
                    .font(AppFont.medium(15))
                    .foregroundStyle(AppColors.textPrimary)

                HStack(spacing: AppSpacing.xs) {
                    Text(L10n.stageOfTotal(learningPath.currentStageIndex + 1, total: learningPath.stages.count))
                        .font(AppFont.medium(13))
                        .foregroundStyle(AppColors.textSecondary)

                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color(hex: "E8E0FF"))
                                .frame(height: 6)

                            Capsule()
                                .fill(AppColors.primaryIndigo)
                                .frame(
                                    width: max(0, geometry.size.width * learningPath.overallProgress),
                                    height: 6
                                )
                        }
                    }
                    .frame(width: 60, height: 6)
                }
            }

            HStack(spacing: AppSpacing.sm) {
                Image(badgeImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 3) {
                    Text(currentStage.title)
                        .font(AppFont.medium(15))
                        .foregroundStyle(AppColors.textPrimary)

                    Text(currentStage.description)
                        .font(AppFont.regular(13))
                        .foregroundStyle(AppColors.textSecondary)
                }

                Spacer()
            }
            .padding(AppSpacing.md)
            .background(AppColors.backgroundCard)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large))
            .appShadow(radius: 6, y: 3)

            Button(action: onViewPath) {
                HStack {
                    Spacer()
                    Text(String(localized: "View full path"))
                        .font(AppFont.medium(16))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .semibold))
                    Spacer()
                }
                .foregroundStyle(.white)
                .padding(.vertical, 16)
                .background(
                    Color(AppColors.primaryDark)
                )
                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.small))
            }
        }
    }
}

#Preview {
    let path = MockData.learningPath
    let stage = path.stages.first(where: { $0.state == .current })!

    LearningPathSummaryCard(
        learningPath: path,
        currentStage: stage,
        onViewPath: {}
    )
    .padding()
    .background(AppColors.backgroundPrimary)
}
