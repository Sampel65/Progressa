//
//  CelebrationOverlay.swift
//  task
//
//  Created by Samson Oluwapelumi on 08/02/2026.
//

import SwiftUI

struct CelebrationOverlay: View {
    let achievement: Achievement
    let onDismiss: () -> Void
    let onShare: () -> Void

    @State private var badgeScale: CGFloat = 0.3
    @State private var badgeOpacity: Double = 0
    @State private var contentOpacity: Double = 0
    @State private var showConfetti = false
    @State private var backgroundOpacity: Double = 0
    @State private var ringsScale: CGFloat = 0.6
    @State private var raysRotation: Double = 0
    @State private var raysOpacity: Double = 0

    var body: some View {
        ZStack {
            // Dimmed background
            Color(hex: "1A1A2E").opacity(backgroundOpacity * 0.75)
                .ignoresSafeArea()
                .onTapGesture { dismissWithAnimation() }

            VStack(spacing: 0) {
                Spacer()

                // Confetti burst
                if showConfetti {
                    ConfettiView()
                        .frame(height: 200)
                        .allowsHitTesting(false)
                }

                // Badge area with starburst
                ZStack {
                    // Starburst rays
                    CelebrationRaysView()
                        .frame(width: 260, height: 260)
                        .opacity(raysOpacity)
                        .rotationEffect(.degrees(raysRotation))

                    // Pulsing rings
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .strokeBorder(
                                colorForCategory(achievement.category).opacity(0.15 - Double(index) * 0.04),
                                lineWidth: 2
                            )
                            .frame(
                                width: 130 + CGFloat(index) * 32,
                                height: 130 + CGFloat(index) * 32
                            )
                            .scaleEffect(showConfetti ? 1.3 : ringsScale)
                            .opacity(showConfetti ? 0 : 0.5)
                            .animation(
                                .easeOut(duration: 1.8)
                                .repeatForever(autoreverses: false)
                                .delay(Double(index) * 0.35),
                                value: showConfetti
                            )
                    }

                    // Gradient badge ring
                    Circle()
                        .strokeBorder(
                            AngularGradient(
                                colors: [
                                    colorForCategory(achievement.category),
                                    colorForCategory(achievement.category).opacity(0.3),
                                    colorForCategory(achievement.category)
                                ],
                                center: .center
                            ),
                            lineWidth: 4
                        )
                        .frame(width: 120, height: 120)
                        .scaleEffect(badgeScale)
                        .opacity(badgeOpacity)

                    // Badge icon
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
                        .frame(width: 108, height: 108)
                        .overlay(
                            Image(systemName: achievement.iconName)
                                .font(.system(size: 44, weight: .semibold))
                                .foregroundStyle(.white)
                        )
                        .scaleEffect(badgeScale)
                        .opacity(badgeOpacity)
                }

                // Text content
                VStack(spacing: 10) {
                    Text("Achievement Unlocked!")
                        .font(AppFont.bold(24))
                        .foregroundStyle(.white)

                    Text(achievement.title)
                        .font(AppFont.bold(18))
                        .foregroundStyle(colorForCategory(achievement.category))

                    Text(achievement.description)
                        .font(AppFont.regular(15))
                        .foregroundStyle(.white.opacity(0.75))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .padding(.top, 20)
                .opacity(contentOpacity)

                // Action buttons
                VStack(spacing: 12) {
                    Button(action: onShare) {
                        HStack(spacing: 8) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 15, weight: .semibold))
                            Text("Share Achievement")
                                .font(AppFont.bold(15))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            colorForCategory(achievement.category),
                                            colorForCategory(achievement.category).opacity(0.8)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                    }

                    Button(action: { dismissWithAnimation() }) {
                        Text("Continue")
                            .font(AppFont.medium(15))
                            .foregroundStyle(.white.opacity(0.65))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, 32)
                .padding(.top, 28)
                .opacity(contentOpacity)

                Spacer()
            }
        }
        .onAppear { animate() }
    }

    // MARK: - Animations

    private func animate() {
        withAnimation(.easeOut(duration: 0.3)) {
            backgroundOpacity = 1
        }

        withAnimation(.spring(response: 0.7, dampingFraction: 0.55).delay(0.2)) {
            badgeScale = 1.0
            badgeOpacity = 1
        }

        withAnimation(.easeOut(duration: 0.6).delay(0.35)) {
            raysOpacity = 0.6
        }

        withAnimation(.linear(duration: 50).repeatForever(autoreverses: false)) {
            raysRotation = 360
        }

        withAnimation(.easeOut(duration: 0.5).delay(0.5)) {
            contentOpacity = 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            showConfetti = true
        }
    }

    private func dismissWithAnimation() {
        withAnimation(.easeIn(duration: 0.25)) {
            backgroundOpacity = 0
            badgeScale = 0.5
            badgeOpacity = 0
            contentOpacity = 0
            raysOpacity = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
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

// MARK: - Celebration Rays

/// Reuses the shared 8-ray starburst but with lighter colours
/// suited for the dark celebration overlay background.
private struct CelebrationRaysView: View {
    var body: some View {
        BadgeStarburstView(
            fillColor: .white,
            strokeColor: Color(hex: "B0BBDA")
        )
    }
}

// MARK: - Confetti View

struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    @State private var isActive = false

    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(particle.color)
                    .frame(width: particle.width, height: particle.height)
                    .offset(
                        x: isActive ? particle.targetX : 0,
                        y: isActive ? particle.targetY : -100
                    )
                    .opacity(isActive ? 0 : 1)
                    .rotationEffect(.degrees(isActive ? particle.rotation : 0))
            }
        }
        .onAppear {
            generateParticles()
            withAnimation(.easeOut(duration: 2.5)) {
                isActive = true
            }
        }
    }

    private func generateParticles() {
        let colors: [Color] = [
            AppColors.primaryIndigo, AppColors.primaryLight,
            AppColors.accentOrange, AppColors.accentCoral,
            AppColors.badgeEarned, AppColors.successGreen,
            .white.opacity(0.9),
        ]

        particles = (0..<35).map { _ in
            ConfettiParticle(
                id: UUID(),
                color: colors.randomElement()!,
                width: CGFloat.random(in: 4...8),
                height: CGFloat.random(in: 8...16),
                targetX: CGFloat.random(in: -200...200),
                targetY: CGFloat.random(in: -50...280),
                rotation: Double.random(in: -540...540)
            )
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id: UUID
    let color: Color
    let width: CGFloat
    let height: CGFloat
    let targetX: CGFloat
    let targetY: CGFloat
    let rotation: Double
}

#Preview {
    CelebrationOverlay(
        achievement: MockData.achievements[0],
        onDismiss: {},
        onShare: {}
    )
}
