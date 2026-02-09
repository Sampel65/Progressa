//
//  SignupView.swift
//  task
//
//  Created by Samson Oluwapelumi on 06/02/2026.
//


import SwiftUI
import DotLottie


struct SignupView: View {
    let authStore: AuthStore
    let onSignIn: () -> Void
    let onBack: () -> Void

    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isPasswordVisible = false
    @State private var isConfirmVisible = false
    @State private var agreedToTerms = false
    @State private var showSuccess = false

    @State private var headerOpacity: Double = 0
    @State private var formOffset: CGFloat = 30
    @State private var formOpacity: Double = 0

    @FocusState private var focusedField: Field?

    private enum Field: Hashable { case name, email, password, confirm }

    var body: some View {
        ZStack {
            AppColors.backgroundPrimary.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    signupHeader
                        .opacity(headerOpacity)


                    formCard
                        .padding(.horizontal, 24)
                        .padding(.top, -32)
                        .offset(y: formOffset)
                        .opacity(formOpacity)

                    signInLink
                        .padding(.top, 24)
                        .opacity(formOpacity)

                    Spacer(minLength: 40)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .ignoresSafeArea(edges: .top)

            if showSuccess {
                successOverlay
            }
        }
        .onAppear { animateIn() }
    }


    private var signupHeader: some View {
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
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.04))
                        .frame(width: 180, height: 180)
                        .offset(x: 100, y: -40)

                    Circle()
                        .fill(Color.white.opacity(0.03))
                        .frame(width: 140, height: 140)
                        .offset(x: -110, y: 50)
                }
            )

            VStack(alignment: .leading, spacing: 0) {
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
                    Text(String(localized: "Create Account"))
                        .font(AppFont.bold(30))
                        .foregroundStyle(.white)

                    Text(String(localized: "Start your learning journey today"))
                        .font(AppFont.regular(15))
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 52)
            }
            .frame(height: 280)
        }
    }


    private var formCard: some View {
        VStack(spacing: 18) {
            AuthTextField(
                icon: "person.fill",
                placeholder: String(localized: "Full name"),
                text: $fullName,
                autocapitalization: .words
            )
            .focused($focusedField, equals: .name)
            .submitLabel(.next)
            .onSubmit { focusedField = .email }

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

            AuthSecureField(
                icon: "lock.fill",
                placeholder: String(localized: "Password (min 8 characters)"),
                text: $password,
                isVisible: $isPasswordVisible
            )
            .focused($focusedField, equals: .password)
            .submitLabel(.next)
            .onSubmit { focusedField = .confirm }

            if !password.isEmpty {
                passwordStrengthBar
            }

            AuthSecureField(
                icon: "lock.rotation",
                placeholder: String(localized: "Confirm password"),
                text: $confirmPassword,
                isVisible: $isConfirmVisible
            )
            .focused($focusedField, equals: .confirm)
            .submitLabel(.done)
            .onSubmit { signUp() }

            termsToggle

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

            Button(action: signUp) {
                ZStack {
                    if authStore.isLoading {
                        LottieOrFallback(name: "loading_dots", loop: true) {
                            ProgressView()
                                .tint(.white)
                        }
                        .frame(height: 24)
                    } else {
                        Text(String(localized: "Create Account"))
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
                                colors: canSubmit
                                    ? [AppColors.primaryIndigo, AppColors.primaryLight]
                                    : [AppColors.badgeLocked, AppColors.badgeLocked.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(
                            color: canSubmit ? AppColors.primaryIndigo.opacity(0.35) : .clear,
                            radius: 12, y: 6
                        )
                )
            }
            .disabled(!canSubmit || authStore.isLoading)
            .padding(.top, 4)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.08), radius: 16, y: 8)
        )
    }


    private var passwordStrength: (text: String, fraction: Double, color: Color) {
        let len = password.count
        switch len {
        case 0: return ("", 0, .clear)
        case 1...4: return (String(localized: "Weak"), 0.25, AppColors.accentCoral)
        case 5...7: return (String(localized: "Fair"), 0.5, AppColors.accentOrange)
        case 8...11: return (String(localized: "Good"), 0.75, Color(hex: "FFD700"))
        default: return (String(localized: "Strong"), 1.0, AppColors.successGreen)
        }
    }

    private var passwordStrengthBar: some View {
        VStack(alignment: .leading, spacing: 6) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(hex: "F2F2F7"))
                        .frame(height: 4)

                    Capsule()
                        .fill(passwordStrength.color)
                        .frame(width: geo.size.width * passwordStrength.fraction, height: 4)
                        .animation(.easeOut(duration: 0.3), value: password)
                }
            }
            .frame(height: 4)

            Text(passwordStrength.text)
                .font(AppFont.medium(11))
                .foregroundStyle(passwordStrength.color)
        }
        .padding(.horizontal, 4)
        .transition(.opacity)
    }


    private var termsToggle: some View {
        Button { agreedToTerms.toggle() } label: {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .strokeBorder(
                            agreedToTerms ? AppColors.primaryIndigo : Color(hex: "D1D1D6"),
                            lineWidth: 1.5
                        )
                        .frame(width: 22, height: 22)

                    if agreedToTerms {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(AppColors.primaryIndigo)
                            .frame(width: 22, height: 22)
                            .overlay(
                                Image(systemName: "checkmark")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(.white)
                            )
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: agreedToTerms)

                Text(String(localized: "I agree to the Terms of Service & Privacy Policy"))
                    .font(AppFont.regular(13))
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.leading)
            }
        }
        .buttonStyle(.plain)
    }


    private var signInLink: some View {
        Button(action: onSignIn) {
            HStack(spacing: 4) {
                Text(String(localized: "Already have an account?"))
                    .font(AppFont.regular(14))
                    .foregroundStyle(AppColors.textSecondary)

                Text(String(localized: "Sign In"))
                    .font(AppFont.bold(14))
                    .foregroundStyle(AppColors.primaryIndigo)
            }
        }
    }


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

                Text(String(localized: "Account Created!"))
                    .font(AppFont.bold(24))
                    .foregroundStyle(.white)

                Text(String(localized: "Let's start learning"))
                    .font(AppFont.regular(15))
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .transition(.opacity)
    }


    private var canSubmit: Bool {
        !fullName.trimmingCharacters(in: .whitespaces).isEmpty
        && !email.isEmpty
        && password.count >= 8
        && password == confirmPassword
        && agreedToTerms
    }


    private func signUp() {
        guard canSubmit else { return }
        focusedField = nil
        authStore.clearError()

        Task {
            let success = await authStore.signUp(
                name: fullName,
                email: email,
                password: password,
                confirmPassword: confirmPassword
            )
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

#Preview {
    SignupView(
        authStore: AuthStore(),
        onSignIn: {},
        onBack: {}
    )
}
