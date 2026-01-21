//
//  ReviewService.swift
//  TLMS-project-main
//
//  Service for managing course reviews and ratings
//

import Foundation
import Supabase
import Combine

@MainActor
class ReviewService: ObservableObject {
    let supabase: SupabaseClient
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init() {
        self.supabase = SupabaseManager.shared.client
    }
    
    // MARK: - Fetch Reviews
    
    func fetchReviews(for courseID: UUID) async -> [CourseReview] {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            // Join with user_profiles to get the reviewer name
            // Note: In Supabase, you can join by specifying the relation
            let reviews: [CourseReview] = try await supabase
                .from("course_reviews")
                .select("""
                    id,
                    course_id,
                    user_id,
                    rating,
                    review_text,
                    is_visible,
                    created_at,
                    user_profiles!inner(
                        full_name
                    )
                """)
                .eq("course_id", value: courseID)
                .eq("is_visible", value: true)
                .order("created_at", ascending: false)
                .execute()
                .value
            
            print("Fetched reviews:", reviews.count)

            return reviews
        } catch {
            print("❌ Error fetching reviews: \(error)")
            errorMessage = "Failed to fetch reviews: \(error.localizedDescription)"
            return []
        }
    }
    
    func fetchEducatorReviews(for educatorID: UUID) async -> [CourseReview] {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            // Fetch reviews for all courses owned by this educator
            // First get course IDs
            let courses: [Course] = try await supabase
                .from("courses")
                .select("id")
                .eq("educator_id", value: educatorID.uuidString)
                .execute()
                .value
            
            let courseIDs = courses.map { $0.id } 
            if courseIDs.isEmpty { return [] }
            
            let reviews: [CourseReview] = try await supabase
                .from("course_reviews")
                .select("""
                    *,
                    user_profiles(full_name)
                """)
                .in("course_id", values: courseIDs)
                .order("created_at", ascending: false)
                .execute()
                .value
            return reviews
        } catch {
            print("❌ Error fetching educator reviews: \(error)")
            errorMessage = "Failed to fetch educator reviews: \(error.localizedDescription)"
            return []
        }
    }
    
    // MARK: - Submit/Update Review
    
    func submitReview(courseID: UUID, userID: UUID, rating: Int, reviewText: String?) async -> Bool {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        struct ReviewSubmission: Encodable {
            let course_id: UUID
            let user_id: UUID
            let rating: Int
            let review_text: String?
            let is_visible: Bool
        }
        
        do {
            let submission = ReviewSubmission(
                course_id: courseID,
                user_id: userID,
                rating: rating,
                review_text: reviewText,
                is_visible: true
            )
            
            try await supabase
                .from("course_reviews")
                .upsert(submission, onConflict: "course_id,user_id")
                .execute()
            
            return true
        } catch {
            print("❌ Error submitting review: \(error)")
            errorMessage = "Failed to submit review: \(error.localizedDescription)"
            return false
        }
    }
    
    func deleteReview(reviewID: UUID) async -> Bool {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            try await supabase
                .from("course_reviews")
                .delete()
                .eq("id", value: reviewID.uuidString)
                .execute()
            return true
        } catch {
            errorMessage = "Failed to delete review: \(error.localizedDescription)"
            return false
        }
    }
    
    // MARK: - Moderation
    
    func toggleReviewVisibility(reviewID: UUID, isVisible: Bool) async -> Bool {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            try await supabase
                .from("course_reviews")
                .update(["is_visible": isVisible])
                .eq("id", value: reviewID.uuidString)
                .execute()
            return true
        } catch {
            errorMessage = "Failed to update review visibility: \(error.localizedDescription)"
            return false
        }
    }
    
    // MARK: - Helper
    
    func fetchUserReview(courseID: UUID, userID: UUID) async -> CourseReview? {
        do {
            let reviews: [CourseReview] = try await supabase
                .from("course_reviews")
                .select()
                .eq("course_id", value: courseID)
                .eq("user_id", value: userID)
                .execute()
                .value
            return reviews.first
        } catch {
            return nil
        }
    }
}
