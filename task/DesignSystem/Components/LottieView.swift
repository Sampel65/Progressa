//
//  LottieView.swift
//  task
//
//  Created by Samson Oluwapelumi on 08/02/2026.
//

import SwiftUI
import DotLottie

// ═══════════════════════════════════════════════════════
// MARK: - DotLottie Animation Wrapper
// ═══════════════════════════════════════════════════════

/// A convenience SwiftUI wrapper around `DotLottieAnimation`.
///
/// Loads a `.json` or `.lottie` file from the app bundle by name.
///
/// Usage:
/// ```
/// LottieView(name: "success_checkmark", loop: false)
///     .frame(width: 200, height: 200)
/// ```
struct LottieView: View {
    let name: String
    var loop: Bool = true
    var speed: Float = 1.0

    var body: some View {
        DotLottieAnimation(
            fileName: name,
            config: AnimationConfig(
                autoplay: true,
                loop: loop,
                speed: speed
            )
        ).view()
    }
}

// ═══════════════════════════════════════════════════════
// MARK: - Lottie + SwiftUI Fallback
// ═══════════════════════════════════════════════════════

/// Attempts to load a DotLottie animation from the bundle;
/// falls back to a SwiftUI view if the file isn't found.
struct LottieOrFallback<Fallback: View>: View {
    let name: String
    var loop: Bool = true
    var speed: Float = 1.0
    @ViewBuilder let fallback: () -> Fallback

    private var animationExists: Bool {
        Bundle.main.url(forResource: name, withExtension: "json") != nil
        || Bundle.main.url(forResource: name, withExtension: "lottie") != nil
    }

    var body: some View {
        if animationExists {
            LottieView(name: name, loop: loop, speed: speed)
        } else {
            fallback()
        }
    }
}
