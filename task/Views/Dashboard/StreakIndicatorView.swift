//
//  StreakIndicatorView.swift
//  task
//
//  Created by Samson Oluwapelumi on 08/02/2026.
//


import SwiftUI

struct StreakBadge: View {
    let currentStreak: Int

    var body: some View {
        HStack(spacing: 4) {
            Text("🔥")
                .font(.system(size: 14))
            Text("\(currentStreak) \(currentStreak == 1 ? "day" : "days")")
                .font(AppFont.medium(14))
                .foregroundStyle(AppColors.textPrimary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(.white.opacity(0.7))
        )
    }
}

struct StreakIndicatorView: View {
    let currentStreak: Int
    let longestStreak: Int

    @State private var flameScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.3

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .fill(AppColors.streakFlame.opacity(glowOpacity))
                    .frame(width: 56, height: 56)
                    .blur(radius: 8)

                Circle()
                    .fill(AppGradients.streak)
                    .frame(width: 48, height: 48)

                Image(systemName: "flame.fill")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
                    .scaleEffect(flameScale)
            }

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(currentStreak)")
                        .font(AppFont.bold(28))
                        .foregroundStyle(AppColors.streakFlame)

                    Text(currentStreak == 1 ? "day" : "day streak")
                        .font(AppTypography.callout)
                        .foregroundStyle(AppColors.textPrimary)
                }

                Text("Longest: \(longestStreak) days")
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: AppSpacing.xxs) {
                Text("This week")
                    .font(AppTypography.captionSmall)
                    .foregroundStyle(AppColors.textSecondary)

                HStack(spacing: 6) {
                    ForEach(0..<7, id: \.self) { day in
                        Circle()
                            .fill(
                                day < min(currentStreak, 7)
                                ? AppColors.streakFlame
                                : AppColors.badgeLocked.opacity(0.3)
                            )
                            .frame(width: 10, height: 10)
                    }
                }
            }
        }
        .padding(AppSpacing.md)
        .cardStyle()
        .onAppear {
            withAnimation(
                .easeInOut(duration: 1.2)
                .repeatForever(autoreverses: true)
            ) {
                flameScale = 1.15
                glowOpacity = 0.6
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        StreakBadge(currentStreak: 3)
        StreakIndicatorView(currentStreak: 7, longestStreak: 14)
            .padding()
    }
    .background(AppColors.backgroundPrimary)
}
