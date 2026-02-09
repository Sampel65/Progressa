//
//  StageItemView.swift
//  task
//

import SwiftUI

// MARK: - Badge Anchor Preference

private struct BadgeAnchorKey: PreferenceKey {
    static var defaultValue: [Int: Anchor<CGPoint>] = [:]
    static func reduce(
        value: inout [Int: Anchor<CGPoint>],
        nextValue: () -> [Int: Anchor<CGPoint>]
    ) {
        value.merge(nextValue()) { _, new in new }
    }
}

// MARK: - Serpentine Stage Grid

struct SerpentineStageGrid: View {
    let stages: [Stage]
    var onCompletedStageTap: ((Stage) -> Void)?
    var onCurrentStageTap: ((Stage) -> Void)?

    private var rows: [[Stage]] {
        stride(from: 0, to: stages.count, by: 2).map { i in
            Array(stages[i..<min(i + 2, stages.count)])
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            ForEach(Array(rows.enumerated()), id: \.offset) { rowIndex, rowStages in
                serpentineRow(rowStages, rowIndex: rowIndex)
            }
        }
        .backgroundPreferenceValue(BadgeAnchorKey.self) { anchors in
            GeometryReader { proxy in
                let positions: [Int: CGPoint] = Dictionary(
                    uniqueKeysWithValues: anchors.compactMap { key, anchor in
                        (key, proxy[anchor])
                    }
                )
                SerpentineConnectors(stages: stages, positions: positions)
            }
        }
    }

    // MARK: - Row Layout

    @ViewBuilder
    private func serpentineRow(_ rowStages: [Stage], rowIndex: Int) -> some View {
        let isReversed = rowIndex % 2 == 1

        if rowStages.count == 1 {
            HStack {
                Spacer()
                PathStageBadge(stage: rowStages[0], onTap: tapAction(for: rowStages[0]))
                Spacer()
            }
        } else {
            let leftStage  = isReversed ? rowStages[1] : rowStages[0]
            let rightStage = isReversed ? rowStages[0] : rowStages[1]

            HStack(alignment: .top, spacing: 0) {
                PathStageBadge(stage: leftStage, onTap: tapAction(for: leftStage))
                    .frame(maxWidth: .infinity)
                PathStageBadge(stage: rightStage, onTap: tapAction(for: rightStage))
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func tapAction(for stage: Stage) -> (() -> Void)? {
        switch stage.state {
        case .completed:
            return { onCompletedStageTap?(stage) }
        case .current:
            return { onCurrentStageTap?(stage) }
        case .locked:
            return nil
        }
    }
}

// MARK: - Path Stage Badge

struct PathStageBadge: View {
    let stage: Stage
    var onTap: (() -> Void)?

    @State private var animatedProgress: Double = 0

    private var badgeImageName: String {
        switch stage.state {
        case .completed:
            return stage.stageNumber % 2 == 1 ? "purple_badge" : "purple_badge"
        case .current:
            return "blue_badge"
        case .locked:
            return "Grey_badge"
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            badgeIconWrapper
                .frame(width: 106, height: 106)
                .anchorPreference(key: BadgeAnchorKey.self, value: .center) {
                    [stage.stageNumber: $0]
                }

            Text(stage.title)
                .font(AppFont.medium(13))
                .foregroundStyle(
                    stage.state == .locked
                    ? AppColors.textSecondary
                    : AppColors.textPrimary
                )
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .frame(width: 120)

            if stage.state == .current {
                Text(stage.description)
                    .font(AppFont.regular(11))
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .frame(width: 120)
            }
        }
        .onAppear {
            if stage.state == .current {
                withAnimation(.easeOut(duration: 1.0).delay(0.3)) {
                    animatedProgress = stage.progressFraction
                }
            }
        }
    }

    @ViewBuilder
    private var badgeIconWrapper: some View {
        if let onTap {
            Button(action: onTap) {
                badgeIcon
            }
            .buttonStyle(.plain)
        } else {
            badgeIcon
        }
    }

    // MARK: - Badge Icon

    private let pageBg = Color(hex: "F5F5FA")

    private var badgeIcon: some View {
        ZStack {
            Circle()
                .fill(pageBg)
                .frame(
                    width:  stage.state == .completed ? 80 : 96,
                    height: stage.state == .completed ? 80 : 96
                )

            if stage.state == .locked {
                Circle()
                    .fill(pageBg)
                    .frame(width: 96, height: 96)
                Circle()
                    .stroke(Color(hex: "D1D1D6").opacity(0.35), lineWidth: 5)
                    .frame(width: 100, height: 100)
            }

            if stage.state == .current {
                Circle()
                    .fill(pageBg)
                    .frame(width: 96, height: 96)
                Circle()
                    .stroke(Color(hex: "D1E3F8"), lineWidth: 5)
                    .frame(width: 100, height: 100)

                Circle()
                    .trim(from: 0, to: animatedProgress)
                    .stroke(
                        Color(hex: "2467E3"),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))
            }

            Image(badgeImageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 82, height: 80)
        }
    }
}

// MARK: - Serpentine Connectors

struct SerpentineConnectors: View {
    let stages: [Stage]
    let positions: [Int: CGPoint]

    private func edgeOffset(for stage: Stage) -> CGFloat {
        switch stage.state {
        case .completed: return 13
        case .current, .locked: return 10
        }
    }

    var body: some View {
        if positions.count >= 2 {
            Canvas { ctx, _ in
                for i in 0..<(stages.count - 1) {
                    draw(index: i, in: &ctx)
                }
            }
        }
    }

    // MARK: - Drawing

    private func draw(index i: Int, in ctx: inout GraphicsContext) {
        let from = stages[i]
        let to   = stages[i + 1]

        guard let a = positions[from.stageNumber],
              let b = positions[to.stageNumber] else { return }

        let completed = from.state == .completed
        let color: Color = completed
            ? Color(hex: "9B8FFF").opacity(0.45)
            : Color(hex: "D1D1D6").opacity(0.45)
        let style = StrokeStyle(
            lineWidth: 1.5,
            lineCap: .round,
            dash: completed ? [] : [6, 4]
        )

        let fromRow = i / 2
        let toRow   = (i + 1) / 2

        if fromRow == toRow {
            drawHorizontalLine(
                a: a, b: b,
                fromStage: from, toStage: to,
                color: color, style: style, in: &ctx
            )
        } else {
            let rightSide = (fromRow % 2 == 0)
            drawUTurn(
                a: a, b: b,
                fromStage: from, toStage: to,
                rightSide: rightSide,
                color: color, style: style, in: &ctx
            )
        }
    }

    // MARK: Horizontal (within-row)

    private func drawHorizontalLine(
        a: CGPoint, b: CGPoint,
        fromStage: Stage, toStage: Stage,
        color: Color, style: StrokeStyle,
        in ctx: inout GraphicsContext
    ) {
        // Determine which position is left vs right on screen
        let aIsLeft = a.x < b.x
        let leftStage  = aIsLeft ? fromStage : toStage
        let rightStage = aIsLeft ? toStage : fromStage
        let leftPt     = aIsLeft ? a : b
        let rightPt    = aIsLeft ? b : a

        let leftX  = leftPt.x + edgeOffset(for: leftStage)
        let rightX = rightPt.x - edgeOffset(for: rightStage)
        let y      = (a.y + b.y) / 2
        guard rightX > leftX + 4 else { return }

        var p = Path()
        p.move(to:    CGPoint(x: leftX,  y: y))
        p.addLine(to: CGPoint(x: rightX, y: y))
        ctx.stroke(p, with: .color(color), style: style)
    }

    private func drawUTurn(
        a: CGPoint, b: CGPoint,
        fromStage: Stage, toStage: Stage,
        rightSide: Bool,
        color: Color, style: StrokeStyle,
        in ctx: inout GraphicsContext
    ) {
        let fromEdge = edgeOffset(for: fromStage)
        let toEdge   = edgeOffset(for: toStage)

        let startY = a.y + fromEdge      // bottom tip of upper badge
        let endY   = b.y - toEdge        // top tip of lower badge
        guard endY > startY + 4 else { return }

        let vSpan = endY - startY
        let bulge = min(vSpan / 2.0 * (4.0 / 3.0), 110)
        let dir: CGFloat = rightSide ? 1 : -1

        var p = Path()

        if abs(a.x - b.x) > 20 {
            p.move(to: CGPoint(x: a.x, y: startY))
            p.addCurve(
                to:       CGPoint(x: b.x, y: endY),
                control1: CGPoint(x: a.x + bulge * dir, y: startY + vSpan * 0.25),
                control2: CGPoint(x: b.x,               y: endY   - vSpan * 0.30)
            )
        } else {
            let x = a.x
            p.move(to: CGPoint(x: x, y: startY))
            p.addCurve(
                to:       CGPoint(x: x, y: endY),
                control1: CGPoint(x: x + bulge * dir, y: startY),
                control2: CGPoint(x: x + bulge * dir, y: endY)
            )
        }

        ctx.stroke(p, with: .color(color), style: style)
    }
}

#Preview("Serpentine Grid") {
    ScrollView {
        VStack(alignment: .leading, spacing: 0) {
            Text("Stage 3 of 11")
                .font(AppFont.regular(14))
                .foregroundStyle(AppColors.textSecondary)
                .padding(.horizontal, 20)
            Text("Fullstack mobile engineer path")
                .font(AppFont.bold(28))
                .foregroundStyle(AppColors.textPrimary)
                .padding(.horizontal, 20)
                .padding(.bottom, 24)

            SerpentineStageGrid(stages: MockData.learningPath.stages)
                .padding(.horizontal, 20)
        }
        .padding(.top, 60)
    }
    .background(Color(hex: "F5F5FA"))
    .ignoresSafeArea(edges: .top)
}
