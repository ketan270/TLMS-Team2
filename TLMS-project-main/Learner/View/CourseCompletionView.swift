//
//  CourseCompletionView.swift
//  TLMS-project-main
//
//  Created by Chehak on 20/01/26.
//

import Foundation
import SwiftUI
import Supabase

struct CourseCompletionView: View {
    let course: Course
    let userId: UUID
    var onDismiss: () -> Void
    var onViewCertificate: () -> Void
    
    @State private var rating: Int = 0
    @State private var reviewText: String = ""
    @State private var publishedCourses: [Course] = [] // For recommendations
    @State private var isLoadingRecommendations = true
    
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var courseService = CourseService()

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // MARK: - Congratulatory Banner
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                        .padding(.bottom, 8)
                        .shadow(radius: 10)
                    
                    Text("Congratulations!")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("You've completed")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text(course.title)
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text("Completed on \(Date().formatted(date: .long, time: .omitted))")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.top, 4)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 50)
                .background(
                    LinearGradient(
                        colors: [AppTheme.primaryBlue, AppTheme.accentPurple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(30, corners: [.bottomLeft, .bottomRight])
                .shadow(radius: 10)
                .edgesIgnoringSafeArea(.top)
                
                // MARK: - Certificate Action
                VStack(spacing: 20) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Your Certificate")
                                .font(.headline)
                                .foregroundColor(AppTheme.primaryText)
                            Text("Share your achievement")
                                .font(.caption)
                                .foregroundColor(AppTheme.secondaryText)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    HStack(spacing: 16) {
                        // Certificate Preview (Placeholder)
                        VStack {
                            Image(systemName: "doc.text.image.fill")
                                .font(.system(size: 40))
                                .foregroundColor(AppTheme.primaryBlue.opacity(0.6))
                            Text("Certificate")
                                .font(.caption2)
                                .foregroundColor(AppTheme.secondaryText)
                        }
                        .frame(width: 80, height: 100)
                        .background(AppTheme.secondaryGroupedBackground)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(AppTheme.primaryBlue.opacity(0.2), lineWidth: 1)
                        )
                        
                        // Actions
                        VStack(spacing: 12) {
                            Button(action: onViewCertificate) {
                                Label("View Career Certificate", systemImage: "eye.fill")
                                    .font(.headline)
                                    .foregroundColor(AppTheme.primaryBlue)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(AppTheme.primaryBlue.opacity(0.1))
                                    .cornerRadius(12)
                            }
                            
                            Button(action: {
                                // Mock LinkedIn Share
                                // In real app, this would open share sheet or linkedin url scheme
                            }) {
                                Label("Add to LinkedIn", systemImage: "link")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color(red: 0.0, green: 0.47, blue: 0.71)) // LinkedIn Blue
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding()
                    .background(AppTheme.cardBackground)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                }
                
                // MARK: - Recommendations
                VStack(alignment: .leading, spacing: 16) {
                    Text("You might also find these helpful")
                        .font(.headline)
                        .foregroundColor(AppTheme.primaryText)
                        .padding(.horizontal)
                    
                    if isLoadingRecommendations {
                        ProgressView()
                            .padding()
                    } else if publishedCourses.isEmpty {
                        Text("No recommendations available right now.")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.secondaryText)
                            .padding(.horizontal)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(publishedCourses.prefix(3)) { course in
                                    // Mini Course Card for Recommendations
                                    VStack(alignment: .leading, spacing: 8) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.gray.opacity(0.1))
                                                .frame(height: 100)
                                            Image(systemName: "book.fill")
                                                .foregroundColor(AppTheme.primaryBlue)
                                                .font(.largeTitle)
                                        }
                                        
                                        Text(course.title)
                                            .font(.subheadline.bold())
                                            .lineLimit(2)
                                            .foregroundColor(AppTheme.primaryText)
                                        
                                        Text(course.category)
                                            .font(.caption)
                                            .foregroundColor(AppTheme.secondaryText)
                                        
                                        HStack(spacing: 2) {
                                            ForEach(0..<5) { _ in
                                                Image(systemName: "star.fill")
                                                    .font(.caption2)
                                                    .foregroundColor(.orange)
                                            }
                                        }
                                    }
                                    .frame(width: 160)
                                    .padding(12)
                                    .background(AppTheme.cardBackground)
                                    .cornerRadius(12)
                                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                // MARK: - Rate this course
                VStack(spacing: 16) {
                    Text("Rate this course")
                        .font(.headline)
                        .foregroundColor(AppTheme.primaryText)
                    
                    HStack(spacing: 12) {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: star <= rating ? "star.fill" : "star")
                                .font(.title)
                                .foregroundColor(.orange)
                                .onTapGesture {
                                    withAnimation {
                                        rating = star
                                    }
                                }
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(AppTheme.cardBackground)
                .cornerRadius(16)
                .padding(.horizontal)
                
                Spacer(minLength: 40)
            }
        }
        .background(AppTheme.groupedBackground)
        .overlay(
            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding()
            }
            , alignment: .topTrailing
        )
        .task {
            await fetchRecommendations()
        }
    }
    
    private func fetchRecommendations() async {
        // Fetch published courses excluding current one
        // Mock query or reuse logic
        do {
            isLoadingRecommendations = true
             let supabase = SupabaseManager.shared.client
             let result: [Course] = try await supabase
                 .from("courses")
                 .select()
                 .eq("status", value: "published")
                 .neq("id", value: course.id.uuidString)
                 .limit(5)
                 .execute()
                 .value
             
            publishedCourses = result
        } catch {
            print("Error fetching recommendations: \(error)")
        }
        isLoadingRecommendations = false
    }
}

// Extension for specific corner radius
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

