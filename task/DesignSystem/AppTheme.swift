//
//  AppTheme.swift
//  task
//
//  Created by Samson Oluwapelumi on 06/02/2026.
//


import SwiftUI


enum AppFont {

    static func regular(_ size: CGFloat) -> Font {
        .custom("Aeonik-Regular", size: size)
    }

    static func medium(_ size: CGFloat) -> Font {
        .custom("Aeonik-Medium", size: size)
    }

    static func bold(_ size: CGFloat) -> Font {
        .custom("Aeonik-Bold", size: size)
    }

    static func regularItalic(_ size: CGFloat) -> Font {
        .custom("Aeonik-RegularItalic", size: size)
    }
}


enum AppTypography {
    static let callout      = AppFont.medium(15)
    static let footnote     = AppFont.regular(13)
    static let captionSmall = AppFont.regular(11)
}


enum AppColors {
    static let primaryIndigo = Color(hex: "4B3F8F")
    static let primaryLight = Color(hex: "6C5FBC")
    static let primaryDark = Color(hex: "#8636E8")

    static let accentOrange = Color(hex: "FF8C42")
    static let accentAmber = Color(hex: "FFB347")
    static let accentCoral = Color(hex: "FF6B6B")

    static let successGreen = Color(hex: "34C759")
    static let successLight = Color(hex: "A8E6CF")

    static let backgroundPrimary = Color(hex: "F5F5FA")
    static let backgroundCard = Color.white

    static let textPrimary = Color(hex: "1A1A2E")
    static let textSecondary = Color(hex: "8E8E93")

    static let streakFlame = Color(hex: "FF6B35")

    static let badgeEarned = Color(hex: "FFD700")
    static let badgeLocked = Color(hex: "C7C7CC")
}


extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}


enum AppSpacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let xl: CGFloat = 24
}


enum AppCornerRadius {
    static let small: CGFloat = 8
    static let large: CGFloat = 16
}


struct AppShadow: ViewModifier {
    let radius: CGFloat
    let y: CGFloat

    func body(content: Content) -> some View {
        content
            .shadow(color: Color.black.opacity(0.06), radius: radius, x: 0, y: y)
    }
}

extension View {
    func appShadow(radius: CGFloat = 8, y: CGFloat = 4) -> some View {
        modifier(AppShadow(radius: radius, y: y))
    }

    func cardStyle() -> some View {
        self
            .background(AppColors.backgroundCard)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large))
            .appShadow()
    }
}


enum AppGradients {
    static let primary = LinearGradient(
        colors: [AppColors.primaryIndigo, AppColors.primaryLight],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let accent = LinearGradient(
        colors: [AppColors.accentOrange, AppColors.accentAmber],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let success = LinearGradient(
        colors: [AppColors.successGreen, AppColors.successLight],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let streak = LinearGradient(
        colors: [AppColors.streakFlame, AppColors.accentOrange],
        startPoint: .top,
        endPoint: .bottom
    )
}
