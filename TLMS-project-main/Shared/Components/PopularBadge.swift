//
//  PopularBadge.swift
//  TLMS-project-main
//
//  "POPULAR" badge for high-enrollment courses (Coursera-style)
//

import SwiftUI

struct PopularBadge: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .font(.system(size: 10, weight: .bold))
            Text("POPULAR")
                .font(.system(size: 11, weight: .bold))
                .tracking(0.5)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            LinearGradient(
                colors: [Color.orange, Color.red],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(6)
        .shadow(color: Color.orange.opacity(0.4), radius: 4, x: 0, y: 2)
    }
}

// Variant for trending badge
struct TrendingBadge: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 10, weight: .bold))
            Text("TRENDING")
                .font(.system(size: 11, weight: .bold))
                .tracking(0.5)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            LinearGradient(
                colors: [Color.purple, Color.pink],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(6)
        .shadow(color: Color.purple.opacity(0.4), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    VStack(spacing: 20) {
        PopularBadge()
        TrendingBadge()
    }
    .padding()
    .background(Color.gray.opacity(0.2))
}
