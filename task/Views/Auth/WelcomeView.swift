//
//  WelcomeView.swift
//  task
//

import SwiftUI
import DotLottie

// MARK: - Welcome View

struct WelcomeView: View {
    let onGetStarted: () -> Void
    let onSignIn: () -> Void

    // MARK: - Animation State

    @State private var logoScale: CGFloat = 0.3
    @State private var logoOpacity: Double = 0
    @State private var titleOffset: CGFloat = 30
    @State private var titleOpacity: Double = 0
    @State private var subtitleOpacity: Double = 0
    @State private var buttonsOffset: CGFloat = 40
    @State private var buttonsOpacity: Double = 0
    @State private var orbRotation: Double = 0
    @State private var particlePhase: Double = 0

    var body: some View {
        ZStack {
            backgroundGradient

            VStack(spacing: 0) {
                Spacer()

                illustrationArea
                    .padding(.bottom, 32)

                titleSection
                    .padding(.bottom, 40)

                actionButtons
                    .padding(.horizontal, 28)
                    .padding(.bottom, 20)

                signInLink
                    .padding(.bottom, 40)

                Spacer().frame(height: 20)
            }
        }
        .ignoresSafeArea()
        .onAppear { animateEntrance() }
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: "1A1040"),
                    AppColors.primaryDark,
                    AppColors.primaryIndigo.opacity(0.9)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(AppColors.primaryLight.opacity(0.08))
                .frame(width: 300, height: 300)
                .offset(x: -100, y: -200)
                .rotationEffect(.degrees(orbRotation))

            Circle()
                .fill(AppColors.accentOrange.opacity(0.06))
                .frame(width: 200, height: 200)
                .offset(x: 120, y: 100)
                .rotationEffect(.degrees(-orbRotation * 0.7))

            Circle()
                .fill(Color(hex: "FFD700").opacity(0.05))
                .frame(width: 160, height: 160)
                .offset(x: -60, y: 300)
                .rotationEffect(.degrees(orbRotation * 0.5))
        }
    }

    // MARK: - Illustration

    private var illustrationArea: some View {
        ZStack {
            LottieOrFallback(name: "welcome2", loop: true, speed: 0.8) {
                swiftUIFallbackIllustration
            }
            .frame(width: 260, height: 260)
            .scaleEffect(logoScale)
            .opacity(logoOpacity)
        }
    }

    private var swiftUIFallbackIllustration: some View {
        ZStack {
            // Rotating dashed ring
            Circle()
                .strokeBorder(
                    style: StrokeStyle(lineWidth: 2, dash: [8, 6])
                )
                .foregroundStyle(.white.opacity(0.15))
                .frame(width: 220, height: 220)
                .rotationEffect(.degrees(orbRotation))

            Circle()
                .trim(from: 0, to: 0.65)
                .stroke(
                    AngularGradient(
                        colors: [Color(hex: "FFD700"), AppColors.accentOrange, Color(hex: "FFD700").opacity(0)],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .frame(width: 200, height: 200)
                .rotationEffect(.degrees(-90))

            Circle()
                .fill(
                    LinearGradient(
                        colors: [AppColors.primaryIndigo, AppColors.primaryLight],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 160, height: 160)
                .shadow(color: AppColors.primaryIndigo.opacity(0.4), radius: 20, y: 8)

            Image(systemName: "book.closed.fill")
                .font(.system(size: 52, weight: .medium))
                .foregroundStyle(.white)

            Image(systemName: "sparkle")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color(hex: "FFD700"))
                .offset(x: 90, y: -60)
                .opacity(0.8 + sin(particlePhase) * 0.2)

            Image(systemName: "sparkle")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(AppColors.accentOrange)
                .offset(x: -80, y: 70)
                .opacity(0.6 + cos(particlePhase * 1.3) * 0.3)

            Image(systemName: "star.fill")
                .font(.system(size: 10))
                .foregroundStyle(Color(hex: "FFD700").opacity(0.7))
                .offset(x: 70, y: 80)
                .opacity(0.5 + sin(particlePhase * 0.8) * 0.3)
        }
    }

    // MARK: - Title Section

    private var titleSection: some View {
        VStack(spacing: 14) {
            Text(String(localized: "Learning Progress"))
                .font(AppFont.bold(32))
                .foregroundStyle(.white)
                .offset(y: titleOffset)
                .opacity(titleOpacity)

            Text(String(localized: "Track your journey, earn badges,\nand master new skills every day."))
                .font(AppFont.regular(16))
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .opacity(subtitleOpacity)
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 14) {
            Button(action: onGetStarted) {
                Text(String(localized: "Get Started"))
                    .font(AppFont.bold(17))
                    .foregroundStyle(AppColors.primaryIndigo)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 17)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.white)
                            .shadow(color: .white.opacity(0.2), radius: 12, y: 4)
                    )
            }
        }
        .offset(y: buttonsOffset)
        .opacity(buttonsOpacity)
    }

    // MARK: - Sign In Link

    private var signInLink: some View {
        Button(action: onSignIn) {
            HStack(spacing: 4) {
                Text(String(localized: "Already have an account?"))
                    .font(AppFont.regular(14))
                    .foregroundStyle(.white.opacity(0.5))

                Text(String(localized: "Sign In"))
                    .font(AppFont.bold(14))
                    .foregroundStyle(.white)
            }
        }
        .opacity(buttonsOpacity)
    }

    // MARK: - Animations

    private func animateEntrance() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.65).delay(0.2)) {
            logoScale = 1.0
            logoOpacity = 1
        }

        withAnimation(.easeOut(duration: 0.6).delay(0.5)) {
            titleOffset = 0
            titleOpacity = 1
        }

        withAnimation(.easeOut(duration: 0.5).delay(0.7)) {
            subtitleOpacity = 1
        }

        withAnimation(.easeOut(duration: 0.5).delay(0.9)) {
            buttonsOffset = 0
            buttonsOpacity = 1
        }

        withAnimation(.linear(duration: 80).repeatForever(autoreverses: false)) {
            orbRotation = 360
        }

        withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
            particlePhase = .pi * 2
        }
    }
}

#Preview {
    WelcomeView(onGetStarted: {}, onSignIn: {})
}
