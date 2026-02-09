//
//  GreetingHeaderView.swift
//  task
//
//  Created by Samson Oluwapelumi on 08/02/2026.
//

import SwiftUI

struct GreetingHeaderView: View {
    let greeting: String
    let userName: String
    let motivationalMessage: String
    let currentStreak: Int
    let userInitials: String
    var onSignOut: (() -> Void)? = nil

    /// Extra bottom space so the bg image extends behind the top of the "For today" card
    var bottomOverflow: CGFloat = 60

    var body: some View {
        VStack(spacing: 0) {
            // Safe area top padding
            Color.clear.frame(height: 56)

            // === Top bar: Avatar | Streak | Chat ===
            HStack {
                // User initials avatar (with sign-out menu)
                Menu {
                    if let signOut = onSignOut {
                        Button(role: .destructive, action: signOut) {
                            Label(String(localized: "Sign Out"), systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    }
                } label: {
                    Circle()
                        .fill(Color(hex: "DDD5F3").opacity(0.85))
                        .frame(width: 44, height: 44)
                        .overlay(
                            Text(userInitials)
                                .font(AppFont.bold(15))
                                .foregroundStyle(Color(hex: "4B3F8F"))
                        )
                }

                Spacer()

                // Streak badge
                HStack(spacing: 5) {
                    Image("flame")
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 16, height: 16)
                        .foregroundStyle(Color(hex: "FF6B35"))

                    Text(L10n.streakDays(currentStreak))
                        .font(AppFont.medium(14))
                        .foregroundStyle(Color(hex: "1A1A2E"))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 9)
                .background(
                    Capsule()
                        .fill(.white.opacity(0.6))
                )

                Spacer()

                // Chat / message icon
                Circle()
                    .fill(Color(hex: "DDD5F3").opacity(0.85))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image("messages")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 22, height: 22)
                    )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)

            // === Mascot illustration ===
            Image("robotImage")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 200)
                .padding(.bottom, 16)

            // === Greeting text ===
            Text("\(greeting) \(userName)!")
                .font(AppFont.bold(26))
                .foregroundStyle(Color(hex: "1A1A2E"))
                .multilineTextAlignment(.center)

            // === Motivational subtitle ===
            Text(String(localized: "You're closer than you think 💪"))
                .font(AppFont.regular(16))
                .foregroundStyle(Color(hex: "8E8E93"))
                .padding(.top, 6)

            // Extra bottom space — bg continues behind the "For today" card
            Color.clear.frame(height: bottomOverflow)
        }
        .frame(maxWidth: .infinity)
        .background(
            Image("HeaderBg")
                .resizable()
                .aspectRatio(contentMode: .fill)
        )
        .clipped()
    }
}

#Preview {
    ScrollView {
        GreetingHeaderView(
            greeting: "Good morning",
            userName: "Alex",
            motivationalMessage: "You're closer than you think 💪",
            currentStreak: 3,
            userInitials: "TA"
        )
    }
    .ignoresSafeArea(edges: .top)
}
