//
//  LottieView.swift
//  task
//
//  Created by Samson Oluwapelumi on 06/02/2026.
//


import SwiftUI
import DotLottie


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
