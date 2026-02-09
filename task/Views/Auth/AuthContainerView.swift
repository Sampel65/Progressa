//
//  AuthContainerView.swift
//  task
//

import SwiftUI

// MARK: - Auth Flow Screen

enum AuthScreen {
    case welcome
    case login
    case signup
}

// MARK: - Auth Container View

struct AuthContainerView: View {
    let authStore: AuthStore

    @State private var currentScreen: AuthScreen = .welcome

    var body: some View {
        ZStack {
            switch currentScreen {
            case .welcome:
                WelcomeView(
                    onGetStarted: { navigate(to: .signup) },
                    onSignIn: { navigate(to: .login) }
                )
                .transition(.asymmetric(
                    insertion: .opacity,
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))

            case .login:
                LoginView(
                    authStore: authStore,
                    onSignUp: { navigate(to: .signup) },
                    onBack: { navigate(to: .welcome) }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))

            case .signup:
                SignupView(
                    authStore: authStore,
                    onSignIn: { navigate(to: .login) },
                    onBack: { navigate(to: .welcome) }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            }
        }
        .animation(.easeInOut(duration: 0.35), value: currentScreen)
    }

    private func navigate(to screen: AuthScreen) {
        currentScreen = screen
        authStore.clearError()
    }
}

extension AuthScreen: Equatable {}

#Preview {
    AuthContainerView(authStore: AuthStore())
}
