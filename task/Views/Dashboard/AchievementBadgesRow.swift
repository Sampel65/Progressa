//
//  AchievementBadgesRow.swift
//  task
//
//  Created by Samson Oluwapelumi on 08/02/2026.
//


import SwiftUI

struct AchievementBadgesRow: View {
    let badges: [MockData.DashboardBadge]
    let onViewAll: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text(String(localized: "Badges"))
                .font(AppFont.bold(18))
                .foregroundStyle(AppColors.textPrimary)

            HStack(spacing: AppSpacing.xs) {
                ForEach(Array(badges.enumerated()), id: \.element.id) { index, badge in
                    FigmaBadgeView(
                        badge: badge,
                        imageName: badgeImageName(for: index)
                    )
                    .onTapGesture {
                        onViewAll()
                    }
                }
            }
        }
    }

    private func badgeImageName(for index: Int) -> String {
        switch index {
        case 0: return "blue_badge"
        case 1: return "Special_badge"
        case 2: return "purple_badge"
        default: return "Grey_badge"
        }
    }
}


struct FigmaBadgeView: View {
    let badge: MockData.DashboardBadge
    let imageName: String

    var body: some View {
        VStack(spacing: 8) {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)

            Text(badge.title)
                .font(AppFont.medium(14))
                .foregroundStyle(AppColors.textPrimary)

            Text(badge.subtitle)
                .font(AppFont.regular(11))
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.xs)
    }
}

#Preview {
    AchievementBadgesRow(
        badges: MockData.dashboardBadges,
        onViewAll: {}
    )
    .padding()
    .background(Color.white)
}
