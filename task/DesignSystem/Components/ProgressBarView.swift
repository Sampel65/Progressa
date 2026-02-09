//
//  ProgressBarView.swift
//  task
//
//  Created by Samson Oluwapelumi on 08/02/2026.
//

import SwiftUI

// MARK: - Linear Progress Bar

struct ProgressBarView: View {
    let progress: Double
    var height: CGFloat = 8
    var backgroundColor: Color = AppColors.badgeLocked.opacity(0.3)
    var foregroundGradient: LinearGradient = AppGradients.primary

    @State private var animatedProgress: Double = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(backgroundColor)
                    .frame(height: height)

                Capsule()
                    .fill(foregroundGradient)
                    .frame(width: max(0, geometry.size.width * animatedProgress), height: height)
            }
        }
        .frame(height: height)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animatedProgress = min(max(progress, 0), 1)
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.easeOut(duration: 0.5)) {
                animatedProgress = min(max(newValue, 0), 1)
            }
        }
    }
}

// MARK: - Circular Progress View

struct CircularProgressView: View {
    let progress: Double
    var lineWidth: CGFloat = 6
    var size: CGFloat = 60
    var backgroundColor: Color = AppColors.badgeLocked.opacity(0.2)
    var foregroundGradient: AngularGradient?

    @State private var animatedProgress: Double = 0

    private var defaultGradient: AngularGradient {
        AngularGradient(
            gradient: Gradient(colors: [AppColors.primaryIndigo, AppColors.primaryLight, AppColors.primaryIndigo]),
            center: .center,
            startAngle: .degrees(-90),
            endAngle: .degrees(270)
        )
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(backgroundColor, lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    foregroundGradient ?? defaultGradient,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                animatedProgress = min(max(progress, 0), 1)
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.easeOut(duration: 0.5)) {
                animatedProgress = min(max(newValue, 0), 1)
            }
        }
    }
}

// MARK: - Previews

#Preview("Linear Progress") {
    VStack(spacing: 20) {
        ProgressBarView(progress: 0.3)
        ProgressBarView(progress: 0.7, foregroundGradient: AppGradients.accent)
        ProgressBarView(progress: 1.0, foregroundGradient: AppGradients.success)
    }
    .padding()
}

#Preview("Circular Progress") {
    HStack(spacing: 20) {
        CircularProgressView(progress: 0.3)
        CircularProgressView(progress: 0.65)
        CircularProgressView(progress: 1.0)
    }
    .padding()
}
