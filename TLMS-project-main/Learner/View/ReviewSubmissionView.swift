//
//  ReviewSubmissionView.swift
//  TLMS-project-main
//

import SwiftUI

struct ReviewSubmissionView: View {
    let course: Course
    let userId: UUID
    var existingReview: CourseReview?
    var onSubmissionSuccess: () -> Void
    
    @Environment(\.dismiss) var dismiss
    @StateObject private var reviewService = ReviewService()
    
    @State private var rating: Int = 0
    @State private var reviewText: String = ""
    @State private var isSubmitting = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    VStack(spacing: 16) {
                        Text("How was your experience?")
                            .font(.headline)
                        
                        StarRatingView(rating: $rating)
                        
                        Text(ratingDescription)
                            .font(.subheadline)
                            .foregroundColor(AppTheme.secondaryText)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                }
                
                Section(header: Text("Share more (optional)")) {
                    TextEditor(text: $reviewText)
                        .frame(minHeight: 120)
                        .overlay(
                            Group {
                                if reviewText.isEmpty {
                                    Text("Write your review here...")
                                        .foregroundColor(.gray.opacity(0.5))
                                        .padding(.top, 8)
                                        .padding(.leading, 4)
                                }
                            },
                            alignment: .topLeading
                        )
                }
                
                if let error = reviewService.errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle(existingReview == nil ? "Give Rating" : "Edit Rating")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: handleSubmit) {
                        if isSubmitting {
                            ProgressView()
                        } else {
                            Text("Submit")
                                .bold()
                        }
                    }
                    .disabled(rating == 0 || isSubmitting)
                }
            }
            .onAppear {
                if let review = existingReview {
                    rating = review.rating
                    reviewText = review.reviewText ?? ""
                }
            }
        }
    }
    
    private var ratingDescription: String {
        switch rating {
        case 1: return "Terrible"
        case 2: return "Bad"
        case 3: return "Okay"
        case 4: return "Good"
        case 5: return "Amazing"
        default: return "Select a rating"
        }
    }
    
    private func handleSubmit() {
        Task {
            isSubmitting = true
            let success = await reviewService.submitReview(
                courseID: course.id,
                userID: userId,
                rating: rating,
                reviewText: reviewText.isEmpty ? nil : reviewText
            )
            isSubmitting = false
            
            if success {
                onSubmissionSuccess()
                dismiss()
            }
        }
    }
}
