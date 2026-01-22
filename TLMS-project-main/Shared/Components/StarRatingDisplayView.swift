//
//  StarRatingDisplayView.swift
//  TLMS-project-main
//
//  Display-only star rating for showing course ratings
//

import SwiftUI

struct StarRatingDisplayView: View {
    let rating: Double
    let size: CGFloat
    let color: Color
    let showNumber: Bool
    let ratingCount: Int
    
    init(rating: Double, size: CGFloat = 14, color: Color = .orange, showNumber: Bool = true, ratingCount: Int = 0) {
        self.rating = rating
        self.size = size
        self.color = color
        self.showNumber = showNumber
        self.ratingCount = ratingCount
    }
    
    var body: some View {
        HStack(spacing: 4) {
            // Stars
            HStack(spacing: 2) {
                ForEach(0..<5, id: \.self) { index in
                    Image(systemName: starType(for: index))
                        .font(.system(size: size))
                        .foregroundColor(color)
                }
            }
            
            // Rating number
            if showNumber && rating > 0 {
                Text(String(format: "%.1f", rating))
                    .font(.system(size: size, weight: .semibold))
                    .foregroundColor(AppTheme.primaryText)
                
                // Rating count
                if ratingCount > 0 {
                    Text("(\(formatRatingCount(ratingCount)))")
                        .font(.system(size: size - 1))
                        .foregroundColor(AppTheme.secondaryText)
                }
            }
        }
    }
    
    private func starType(for index: Int) -> String {
        let fillThreshold = Double(index) + 0.5
        
        if rating >= Double(index + 1) {
            return "star.fill"
        } else if rating >= fillThreshold {
            return "star.leadinghalf.filled"
        } else {
            return "star"
        }
    }
    
    private func formatRatingCount(_ count: Int) -> String {
        if count >= 1000 {
            let thousands = Double(count) / 1000.0
            return String(format: "%.1fk", thousands)
        }
        return "\(count)"
    }
}

#Preview {
    VStack(spacing: 20) {
        StarRatingDisplayView(rating: 4.8, ratingCount: 2345)
        StarRatingDisplayView(rating: 3.7, size: 16, ratingCount: 89)
        StarRatingDisplayView(rating: 4.5, showNumber: false)
    }
    .padding()
}
