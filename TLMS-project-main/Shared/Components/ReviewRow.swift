//
//  ReviewRow.swift
//  TLMS-project-main
//
//  A row component to display individual reviews
//

import SwiftUI

struct ReviewRow: View {
    let review: CourseReview
    var onToggleVisibility: (() -> Void)? = nil // For educators
    var showModeration: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(review.reviewerName ?? "Anonymous Learner")
                        .font(.headline)
                        .foregroundColor(AppTheme.primaryText)
                    
                    HStack(spacing: 4) {
                        ForEach(1...5, id: \.self) { index in
                            Image(systemName: index <= review.rating ? "star.fill" : "star")
                                .font(.caption2)
                                .foregroundColor(index <= review.rating ? .orange : .gray.opacity(0.3))
                        }
                        
                        Text("•")
                            .foregroundColor(AppTheme.secondaryText)
                        
                        Text(review.createdAt.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                            .foregroundColor(AppTheme.secondaryText)
                    }
                }
                
                Spacer()
                
                if showModeration {
                    Button(action: { onToggleVisibility?() }) {
                        Label(review.isVisible ? "Hide" : "Unhide", 
                              systemImage: review.isVisible ? "eye.slash" : "eye")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(review.isVisible ? Color.red.opacity(0.1) : Color.green.opacity(0.1))
                            .foregroundColor(review.isVisible ? .red : .green)
                            .cornerRadius(4)
                    }
                }
            }
            
            if let text = review.reviewText, !text.isEmpty {
                Text(text)
                    .font(.subheadline)
                    .foregroundColor(AppTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            if !review.isVisible && showModeration {
                Text("Content Hidden")
                    .font(.caption.italic())
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(AppTheme.secondaryGroupedBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
    }
}
