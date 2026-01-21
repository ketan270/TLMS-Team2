//
//  StarRatingView.swift
//  TLMS-project-main
//
//  A reusable star rating component
//

import SwiftUI

struct StarRatingView: View {
    @Binding var rating: Int
    var maxRating: Int = 5
    var starSize: CGFloat = 30
    var isEditable: Bool = true
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...maxRating, id: \.self) { index in
                Image(systemName: index <= rating ? "star.fill" : "star")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: starSize, height: starSize)
                    .foregroundColor(index <= rating ? .orange : .gray.opacity(0.3))
                    .onTapGesture {
                        if isEditable {
                            withAnimation(.spring()) {
                                rating = index
                            }
                        }
                    }
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        StarRatingView(rating: .constant(3))
        StarRatingView(rating: .constant(4), isEditable: false)
    }
}
