//
//  LoginView.swift
//  task
//
//  Created by Samson Oluwapelumi on 08/02/2026.
//

import SwiftUI
import DotLottie

// ═══════════════════════════════════════════════════════
// MARK: - Login View
// ═══════════════════════════════════════════════════════

struct LoginView: View {
    let authStore: AuthStore
    let onSignUp: () -> Void
    let onBack: () -> Void

    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var showSuccess = false

    // Animation
    @State private var headerOpacity: Double = 0
    @State private var formOffset: CGFloat = 30
    @State private var formOpacity: Double = 0

    @FocusState private var focusedField: Field?

    private enum Field: Hashable { case email, password }

    var body: some View {
        ZStack {
            AppColors.backgroundPrimary.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    // ── Header ──
                    loginHeader
                        .opacity(headerOpacity)

                    // ── Form Card ──
                    formCard
                        .padding(.horizontal, 24)
                        .padding(.top, -32)
                        .offset(y: formOffset)
                        .opacity(formOpacity)

                    // ── Sign Up Link ──
                    signUpLink
                        .padding(.top, 28)
                        .opacity(formOpacity)

                    Spacer(minLength: 40)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .ignoresSafeArea(edges: .top)

            // Success overlay
            if showSuccess {
                successOverlay
            }
        }
        .onAppear { animateIn() }
    }

    // MARK: - Header

    private var loginHeader: some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(
                colors: [AppColors.primaryDark, AppColors.primaryIndigo, AppColors.primaryLight.opacity(0.85)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 280)
            .ignoresSafeArea(edges: .top)
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: 36,
                    bottomTrailingRadius: 36,
                    topTrailingRadius: 0
                )
            )
            .overlay(
                // Decorative circles
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.04))
                        .frame(width: 160, height: 160)
                        .offset(x: -80, y: -20)

                    Circle()
                        .fill(Color.white.opacity(0.03))
                        .frame(width: 120, height: 120)
                        .offset(x: 130, y: 40)
                }
            )

            VStack(alignment: .leading, spacing: 0) {
                // Back button
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(.white.opacity(0.12)))
                }
                .padding(.top, 60)
                .padding(.leading, 24)

                Spacer()

                VStack(alignment: .leading, spacing: 8) {
                    Text(String(localized: "Welcome Back"))
                        .font(AppFont.bold(30))
                        .foregroundStyle(.white)

                    Text(String(localized: "Sign in to continue your learning journey"))
                        .font(AppFont.regular(15))
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 52)
            }
            .frame(height: 280)
        }
    }

    // MARK: - Form Card

    private var formCard: some View {
        VStack(spacing: 22) {
            // Email field
            AuthTextField(
                icon: "envelope.fill",
                placeholder: String(localized: "Email address"),
                text: $email,
                keyboardType: .emailAddress,
                autocapitalization: .never
            )
            .focused($focusedField, equals: .email)
            .submitLabel(.next)
            .onSubmit { focusedField = .password }

            // Password field
            AuthSecureField(
                icon: "lock.fill",
                placeholder: String(localized: "Password"),
                text: $password,
                isVisible: $isPasswordVisible
            )
            .focused($focusedField, equals: .password)
            .submitLabel(.done)
            .onSubmit { signIn() }

            // Error message
            if let error = authStore.error {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 12))
                    Text(error.localizedDescription)
                        .font(AppFont.regular(13))
                }
                .foregroundStyle(AppColors.accentCoral)
                .frame(maxWidth: .infinity, alignment: .leading)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            // Sign In button
            Button(action: signIn) {
                ZStack {
                    if authStore.isLoading {
                        LottieOrFallback(name: "loading_dots", loop: true) {
                            ProgressView()
                                .tint(.white)
                        }
                        .frame(height: 24)
                    } else {
                        Text(String(localized: "Sign In"))
                            .font(AppFont.bold(17))
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [AppColors.primaryIndigo, AppColors.primaryLight],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: AppColors.primaryIndigo.opacity(0.35), radius: 12, y: 6)
                )
            }
            .disabled(authStore.isLoading)
            .padding(.top, 6)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.08), radius: 16, y: 8)
        )
    }

    // MARK: - Sign Up Link

    private var signUpLink: some View {
        Button(action: onSignUp) {
            HStack(spacing: 4) {
                Text(String(localized: "Don't have an account?"))
                    .font(AppFont.regular(14))
                    .foregroundStyle(AppColors.textSecondary)

                Text(String(localized: "Sign Up"))
                    .font(AppFont.bold(14))
                    .foregroundStyle(AppColors.primaryIndigo)
            }
        }
    }

    // MARK: - Success Overlay

    private var successOverlay: some View {
        ZStack {
            Color(hex: "1A1A2E").opacity(0.7)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                LottieOrFallback(name: "success_checkmark", loop: false, speed: 1.2) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(AppColors.successGreen)
                }
                .frame(width: 120, height: 120)

                Text(String(localized: "Welcome back!"))
                    .font(AppFont.bold(24))
                    .foregroundStyle(.white)
            }
        }
        .transition(.opacity)
    }

    // MARK: - Actions

    private func signIn() {
        focusedField = nil
        authStore.clearError()

        Task {
            let success = await authStore.signIn(email: email, password: password)
            if success {
                withAnimation(.easeOut(duration: 0.3)) {
                    showSuccess = true
                }
            }
        }
    }

    private func animateIn() {
        withAnimation(.easeOut(duration: 0.5)) {
            headerOpacity = 1
        }
        withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
            formOffset = 0
            formOpacity = 1
        }
    }
}

// ═══════════════════════════════════════════════════════
// MARK: - Auth Text Field
// ═══════════════════════════════════════════════════════

struct AuthTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(AppColors.textSecondary)
                .frame(width: 20)

            TextField(placeholder, text: $text)
                .font(AppFont.regular(16))
                .foregroundStyle(AppColors.textPrimary)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(autocapitalization)
                .autocorrectionDisabled()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(hex: "F8F8FC"))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(Color(hex: "E8E8EE"), lineWidth: 1)
                )
        )
    }
}

// ═══════════════════════════════════════════════════════
// MARK: - Auth Secure Field
// ═══════════════════════════════════════════════════════

struct AuthSecureField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    @Binding var isVisible: Bool

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(AppColors.textSecondary)
                .frame(width: 20)

            Group {
                if isVisible {
                    TextField(placeholder, text: $text)
                } else {
                    SecureField(placeholder, text: $text)
                }
            }
            .font(AppFont.regular(16))
            .foregroundStyle(AppColors.textPrimary)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)

            Button { isVisible.toggle() } label: {
                Image(systemName: isVisible ? "eye.fill" : "eye.slash.fill")
                    .font(.system(size: 15))
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(hex: "F8F8FC"))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(Color(hex: "E8E8EE"), lineWidth: 1)
                )
        )
    }
}

#Preview {
    LoginView(
        authStore: AuthStore(),
        onSignUp: {},
        onBack: {}
    )
}
