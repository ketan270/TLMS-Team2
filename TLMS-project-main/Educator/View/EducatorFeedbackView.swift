//
//  EducatorFeedbackView.swift
//  TLMS-project-main
//

import SwiftUI

struct EducatorFeedbackView: View {
    let educatorId: UUID
    
    @StateObject private var reviewService = ReviewService()
    @State private var reviews: [CourseReview] = []
    @State private var selectedFilter: ReviewFilter = .all
    
    enum ReviewFilter: String, CaseIterable {
        case all = "All"
        case visible = "Visible"
        case hidden = "Hidden"
    }
    
    var filteredReviews: [CourseReview] {
        switch selectedFilter {
        case .all: return reviews
        case .visible: return reviews.filter { $0.isVisible }
        case .hidden: return reviews.filter { !$0.isVisible }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Filter", selection: $selectedFilter) {
                    ForEach(ReviewFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                if reviewService.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if reviews.isEmpty {
                    ContentUnavailableView(
                        "No Reviews Yet",
                        systemImage: "star.bubble",
                        description: Text("Learner feedback will appear here.")
                    )
                } else {
                    List {
                        ForEach(filteredReviews) { review in
                            ReviewRow(
                                review: review,
                                onToggleVisibility: {
                                    handleToggleVisibility(review)
                                },
                                showModeration: true
                            )
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Course Feedback")
            .background(AppTheme.groupedBackground)
            .onAppear {
                fetchReviews()
            }
            .refreshable {
                fetchReviews()
            }
            .alert("Error", isPresented: Binding(
                get: { reviewService.errorMessage != nil },
                set: { _ in reviewService.errorMessage = nil }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                if let error = reviewService.errorMessage {
                    Text(error)
                }
            }
        }
    }
    
    private func fetchReviews() {
        Task {
            reviews = await reviewService.fetchEducatorReviews(for: educatorId)
        }
    }
    
    private func handleToggleVisibility(_ review: CourseReview) {
        Task {
            let success = await reviewService.toggleReviewVisibility(
                reviewID: review.id,
                isVisible: !review.isVisible
            )
            if success {
                fetchReviews()
            }
        }
    }
}
