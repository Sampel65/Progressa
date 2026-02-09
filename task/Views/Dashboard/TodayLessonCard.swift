//
//  TodayLessonCard.swift
//  task
//
//  Created by Samson Oluwapelumi on 08/02/2026.
//


import SwiftUI

struct TodayLessonCard: View {
    let todayLesson: TodayLesson
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 16) {
                    Text(String(localized: "For today"))
                        .font(AppFont.bold(16))
                        .foregroundStyle(Color(hex: "1A1A2E"))

                    HStack(spacing: 14) {
                        Image("Grey_badge")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)

                        VStack(alignment: .leading, spacing: 5) {
                            Text(todayLesson.lesson.title)
                                .font(AppFont.medium(16))
                                .foregroundStyle(Color(hex: "1A1A2E"))
                                .lineLimit(1)
                                .minimumScaleFactor(0.9)

                            HStack(spacing: 6) {
                                Image("note")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 16, height: 16)

                                Text(todayLesson.lesson.subtitle)
                                    .font(AppFont.regular(14))
                                    .foregroundStyle(Color(hex: "8E8E93"))
                            }
                        }
                    }
                }

                Spacer(minLength: 12)

                Image("arrow_right")
                   
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
            .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)
            .padding(.bottom,42)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        VStack(spacing: 0) {
            Color(hex: "D4C8FF").frame(height: 80)
            Color(hex: "F5F5FA")
        }

        TodayLessonCard(
            todayLesson: MockData.todayLesson,
            onTap: {}
        )
        .padding(.horizontal, 16)
    }
    .frame(height: 200)
}
