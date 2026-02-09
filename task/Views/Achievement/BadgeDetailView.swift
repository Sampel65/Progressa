//
//  BadgeDetailView.swift
//  task
//
//  Created by Samson Oluwapelumi on 08/02/2026.
//


import SwiftUI

struct BadgeDetailView: View {
    let achievement: Achievement
    let onTap: () -> Void

    @State private var isAnimating = false

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                ZStack {
                    if achievement.isEarned {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        colorForCategory(achievement.category).opacity(0.2),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 18,
                                    endRadius: 44
                                )
                            )
                            .frame(width: 80, height: 80)
                    }

                    Circle()
                        .fill(
                            achievement.isEarned
                            ? AnyShapeStyle(
                                LinearGradient(
                                    colors: [
                                        colorForCategory(achievement.category),
                                        colorForCategory(achievement.category).opacity(0.7)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            : AnyShapeStyle(Color(hex: "F2F2F7"))
                        )
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: achievement.iconName)
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundStyle(
                                    achievement.isEarned ? Color.white : AppColors.badgeLocked
                                )
                        )
                        .scaleEffect(isAnimating && achievement.isEarned ? 1.04 : 1.0)
                }

                Text(achievement.title)
                    .font(AppFont.medium(14))
                    .foregroundStyle(
                        achievement.isEarned
                        ? AppColors.textPrimary
                        : AppColors.textSecondary
                    )
                    .lineLimit(1)

                Text(achievement.description)
                    .font(AppFont.regular(11))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)

                if achievement.isEarned, let date = achievement.earnedDate {
                    HStack(spacing: 3) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(AppColors.successGreen)

                        Text(date.formatted(.dateTime.month(.abbreviated).day()))
                            .font(AppFont.regular(10))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                } else {
                    HStack(spacing: 3) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 10))
                        Text("Locked")
                            .font(AppFont.regular(10))
                    }
                    .foregroundStyle(AppColors.badgeLocked)
                }

                Text(achievement.category.localizedTitle)
                    .font(AppFont.medium(9))
                    .foregroundStyle(colorForCategory(achievement.category))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(colorForCategory(achievement.category).opacity(0.1))
                    )
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .opacity(achievement.isEarned ? 1.0 : 0.7)
            )
            .shadow(color: .black.opacity(achievement.isEarned ? 0.06 : 0.03), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
        .onAppear {
            if achievement.isEarned {
                withAnimation(
                    .easeInOut(duration: 2.0)
                    .repeatForever(autoreverses: true)
                ) {
                    isAnimating = true
                }
            }
        }
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

#Preview {
    HStack(spacing: 12) {
        BadgeDetailView(
            achievement: MockData.achievements[0],
            onTap: {}
        )
        BadgeDetailView(
            achievement: MockData.achievements[4],
            onTap: {}
        )
    }
    .padding()
    .background(AppColors.backgroundPrimary)
}
