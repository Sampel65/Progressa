//
//  ContentView.swift
//  task
//

import SwiftUI

struct ContentView: View {
    @State private var router = AppRouter()
    @State private var dependencies = DependencyContainer()

    var body: some View {
        Group {
            switch dependencies.authStore.authState {
            case .unknown:
                splashView

            case .onboarding:
                AuthContainerView(authStore: dependencies.authStore)

            case .authenticated(let profile):
                mainTabView(profile: profile)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: dependencies.authStore.isAuthenticated)
    }

    private var splashView: some View {
        ZStack {
            LinearGradient(
                colors: [AppColors.primaryDark, AppColors.primaryIndigo],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.white)

                ProgressView()
                    .tint(.white)
            }
        }
    }

    @ViewBuilder
    private func mainTabView(profile: UserProfile) -> some View {
        TabView(selection: Binding(
            get: { router.selectedTab },
            set: { newTab in
                if newTab == router.selectedTab {
                    router.resetCurrentTab()
                }
                router.selectedTab = newTab
            }
        )) {
            DashboardView(router: router)
                .tabItem {
                    Label(AppTab.dashboard.title, systemImage: AppTab.dashboard.iconName)
                }
                .tag(AppTab.dashboard)

            LearningPathView(router: router)
                .tabItem {
                    Label(AppTab.learningPath.title, systemImage: AppTab.learningPath.iconName)
                }
                .tag(AppTab.learningPath)

            AchievementView(router: router)
                .tabItem {
                    Label(AppTab.achievements.title, systemImage: AppTab.achievements.iconName)
                }
                .tag(AppTab.achievements)
        }
        .tint(AppColors.primaryIndigo)
        .environment(\.dependencies, dependencies)
        .onAppear {
            dependencies.store.updateUserName(profile.firstName)
        }
        .onChange(of: profile) { _, newProfile in
            dependencies.store.updateUserName(newProfile.firstName)
        }
    }
}

#Preview {
    ContentView()
}
