//
//  AchievementSheetView.swift
//  task
//
//  Created by Samson Oluwapelumi on 08/02/2026.
//


import SwiftUI


struct AchievementSheetView: View {
    let stage: Stage
    let onDismiss: () -> Void


    @State private var isFlipped = false
    @State private var badgeScale: CGFloat = 0.3
    @State private var badgeOpacity: Double = 0
    @State private var raysRotation: Double = 0
    @State private var raysOpacity: Double = 0
    @State private var contentOpacity: Double = 0
    @State private var sheetOffset: CGFloat = 600
    @State private var showConfetti = false
    @State private var showShareSheet = false


    private var achievementTitle: String {
        "\(stage.title) mastery earned"
    }

    private var motivationalMessage: String {
        switch stage.stageNumber {
        case 1:
            return "Every expert was once a beginner. You've laid the foundation for greatness."
        case 2:
            return "Versioned & valiant. You don't just write code. You commit to it."
        case 3:
            return "Components assembled. You've mastered the art of reactive thinking."
        case 4:
            return "Pixel perfect. Your mobile interfaces are a thing of beauty."
        case 5:
            return "Connected & capable. The device bends to your will."
        case 6:
            return "Pathfinder. You navigate code as smoothly as your apps navigate screens."
        case 7:
            return "Architect of the invisible. Your backend is the foundation."
        case 8:
            return "Server whisperer. Express yourself through clean API design."
        case 9:
            return "Guardian of the gates. Security is your second nature."
        case 10:
            return "Quality champion. Your tests are the safety net for greatness."
        case 11:
            return "Launch commander. Your app is ready for the world. 🚀"
        default:
            return "Another milestone conquered. Your dedication is inspiring."
        }
    }

    private var badgeImageName: String {
        "purple_badge"
    }

    private var shareText: String {
        "🏆 I just earned the \"\(stage.title)\" mastery badge on Learning Progress!\n\n\(motivationalMessage)\n\n#LearningProgress #Coding"
    }

    private var totalMinutes: Int {
        stage.lessons.reduce(0) { $0 + $1.durationMinutes }
    }


    var body: some View {
        ZStack {
            Color(hex: "1A1A2E")
                .ignoresSafeArea()
                .onTapGesture { dismissSheet() }

            VStack(spacing: 0) {
                Spacer()

                sheetContent
                    .background(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 24,
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: 24
                        )
                        .fill(Color.white)
                        .ignoresSafeArea(edges: .bottom)
                    )
                    .offset(y: sheetOffset)
            }

            if showConfetti {
                SheetConfettiView()
                    .allowsHitTesting(false)
                    .ignoresSafeArea()
            }
        }
        .onAppear { animateIn() }
        .sheet(isPresented: $showShareSheet) {
            ShareSheetView(activityItems: [shareText])
                .presentationDetents([.medium])
        }
    }


    private var sheetContent: some View {
        VStack(spacing: 20) {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(hex: "D1D1D6"))
                .frame(width: 40, height: 5)
                .padding(.top, 14)

            flipBadgeButton

            badgeArea
                .frame(height: 250)

            Text(achievementTitle)
                .font(AppFont.bold(22))
                .foregroundStyle(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .opacity(contentOpacity)

            Text(motivationalMessage)
                .font(AppFont.regularItalic(15))
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 36)

            shareButton
                .padding(.top, 8)
                .padding(.bottom, 24)
        }
        .padding(.bottom, 16)
    }


    private var flipBadgeButton: some View {
        Button {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                isFlipped.toggle()
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "arrow.trianglehead.2.counterclockwise.rotate.90")
                    .font(.system(size: 13, weight: .medium))
                Text("Flip badge")
                    .font(AppFont.medium(14))
            }
            .foregroundStyle(AppColors.textPrimary)
            .padding(.horizontal, 18)
            .padding(.vertical, 9)
            .background(
                Capsule()
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
            )
            .overlay(
                Capsule()
                    .strokeBorder(Color(hex: "E5E5EA"), lineWidth: 1)
            )
        }
        .opacity(contentOpacity)
    }


    private var badgeArea: some View {
        ZStack {
            StarburstRaysView()
                .frame(width: 280, height: 280)
                .opacity(raysOpacity)
                .rotationEffect(.degrees(raysRotation))

            ZStack {
                Image(badgeImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 243.1, height: 213.017)
                    .rotation3DEffect(
                        .degrees(isFlipped ? 180 : 0),
                        axis: (x: 0, y: 1, z: 0)
                    )
                    .opacity(isFlipped ? 0 : 1)

             
                badgeBackContent
                    .rotation3DEffect(
                        .degrees(isFlipped ? 0 : -180),
                        axis: (x: 0, y: 1, z: 0)
                    )
                    .opacity(isFlipped ? 1 : 0)
            }
            .scaleEffect(badgeScale)
            .opacity(badgeOpacity)
        }
    }


    private var badgeBackContent: some View {
        VStack(spacing: 10) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 34))
                .foregroundStyle(AppColors.primaryIndigo)

            Text("Stage \(stage.stageNumber)")
                .font(AppFont.bold(20))
                .foregroundStyle(AppColors.textPrimary)

            VStack(spacing: 4) {
                Label(
                    "\(stage.lessons.count) lessons completed",
                    systemImage: "book.closed.fill"
                )
                .font(AppFont.regular(13))
                .foregroundStyle(AppColors.textSecondary)

                Label(
                    "\(totalMinutes) min total",
                    systemImage: "clock.fill"
                )
                .font(AppFont.regular(13))
                .foregroundStyle(AppColors.textSecondary)
            }
        }
        .frame(width: 160, height: 160)
        .background(
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "F0EDFF"), Color.white],
                        center: .center,
                        startRadius: 10,
                        endRadius: 80
                    )
                )
                .shadow(color: AppColors.primaryIndigo.opacity(0.15), radius: 12, y: 4)
        )
    }


    private var shareButton: some View {
        Button {
            showShareSheet = true
        } label: {
            Text("Share your achievement")
                .font(AppFont.bold(16))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(AppColors.primaryDark)
                )
        }
        .padding(.horizontal, 24)
    }


    private func animateIn() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
            sheetOffset = 0
        }

        withAnimation(.spring(response: 0.7, dampingFraction: 0.6).delay(0.2)) {
            badgeScale = 1.0
            badgeOpacity = 1
        }

        withAnimation(.easeOut(duration: 0.6).delay(0.35)) {
            raysOpacity = 0.7
        }

        withAnimation(.linear(duration: 40).repeatForever(autoreverses: false)) {
            raysRotation = 360
        }

        withAnimation(.easeOut(duration: 0.45).delay(0.5)) {
            contentOpacity = 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            showConfetti = true
        }
    }

    private func dismissSheet() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
            sheetOffset = 600
            badgeOpacity = 0
            raysOpacity = 0
            contentOpacity = 0
            showConfetti = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            onDismiss()
        }
    }
}


private struct StarburstRaysView: View {
    var body: some View {
        BadgeStarburstView()
    }
}

struct BadgeStarburstView: View {
    var rayCount: Int = 8
    var rayWidthFraction: Double = 0.55
    var fillColor: Color = Color(hex: "D8D5EC")
    var strokeColor: Color = Color(hex: "B0BBDA")

    var body: some View {
        Canvas { context, size in
            let cx = size.width / 2
            let cy = size.height / 2
            let center = CGPoint(x: cx, y: cy)
            let outerR = min(cx, cy)
            let segment = (2 * Double.pi) / Double(rayCount)
            let halfRay = segment * rayWidthFraction / 2

            for i in 0..<rayCount {
                let midAngle = segment * Double(i) - .pi / 2

                let startAngle = midAngle - halfRay
                let endAngle   = midAngle + halfRay

                let tipA = CGPoint(
                    x: cx + outerR * cos(startAngle),
                    y: cy + outerR * sin(startAngle)
                )
                let tipB = CGPoint(
                    x: cx + outerR * cos(endAngle),
                    y: cy + outerR * sin(endAngle)
                )

                var tri = Path()
                tri.move(to: center)
                tri.addLine(to: tipA)
                tri.addLine(to: tipB)
                tri.closeSubpath()

                let fillOpacity = i % 2 == 0 ? 0.18 : 0.10
                context.fill(tri, with: .color(fillColor.opacity(fillOpacity)))

                var edge1 = Path()
                edge1.move(to: center)
                edge1.addLine(to: tipA)

                var edge2 = Path()
                edge2.move(to: center)
                edge2.addLine(to: tipB)

                let lineStyle = StrokeStyle(lineWidth: 0.8)
                context.stroke(edge1, with: .color(strokeColor.opacity(0.25)), style: lineStyle)
                context.stroke(edge2, with: .color(strokeColor.opacity(0.25)), style: lineStyle)
            }
        }
    }
}


private struct SheetConfettiView: View {
    @State private var particles: [SheetParticle] = []
    @State private var isActive = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { p in
                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(p.color)
                        .frame(width: p.width, height: p.height)
                        .position(
                            x: geo.size.width / 2 + (isActive ? p.targetX : CGFloat.random(in: -15...15)),
                            y: isActive ? p.targetY : geo.size.height * 0.35
                        )
                        .opacity(isActive ? 0 : 1)
                        .rotationEffect(.degrees(isActive ? p.rotation : 0))
                }
            }
        }
        .onAppear {
            generateParticles()
            withAnimation(.easeOut(duration: 2.8)) {
                isActive = true
            }
        }
    }

    private func generateParticles() {
        let colors: [Color] = [
            Color(hex: "6C5FBC"), Color(hex: "9B8FFF"),
            Color(hex: "FFD700"), Color(hex: "FF8C42"),
            Color(hex: "FF6B6B"), Color(hex: "34C759"),
            .white.opacity(0.9),
        ]
        particles = (0..<35).map { _ in
            SheetParticle(
                color: colors.randomElement()!,
                width: CGFloat.random(in: 4...8),
                height: CGFloat.random(in: 8...16),
                targetX: CGFloat.random(in: -200...200),
                targetY: CGFloat.random(in: 100...700),
                rotation: Double.random(in: -720...720)
            )
        }
    }
}

private struct SheetParticle: Identifiable {
    let id = UUID()
    let color: Color
    let width: CGFloat
    let height: CGFloat
    let targetX: CGFloat
    let targetY: CGFloat
    let rotation: Double
}


struct ShareSheetView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
    }

    func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: Context
    ) {}
}


#Preview("Achievement Sheet") {
    AchievementSheetView(
        stage: MockData.learningPath.stages[1],
        onDismiss: {}
    )
}
