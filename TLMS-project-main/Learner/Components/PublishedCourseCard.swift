//
//  PublishedCourseCard.swift
//  TLMS-project-main
//
//  Created by Antigravity on 26/01/26.
//

import SwiftUI

struct PublishedCourseCard: View {
    let course: Course
    let isEnrolled: Bool
    let progress: Double
    var onEnroll: () async -> Void
    
    @Environment(\.colorScheme) var colorScheme
    @State private var isEnrolling = false
    @State private var showSuccess = false
    @State private var showPaymentRequired = false
    
    // MARK: - Category Styling
    
    private var categoryColor: Color {
        switch course.category.lowercased() {
        case "design": return AppTheme.accentPurple
        case "development", "programming", "code": return AppTheme.primaryBlue
        case "marketing": return AppTheme.warningOrange
        case "business": return AppTheme.accentTeal
        case "data", "analytics": return AppTheme.successGreen
        case "photography": return .pink
        case "music": return .indigo
        default: return AppTheme.secondaryText
        }
    }
    
    private var categoryIcon: String {
        switch course.category.lowercased() {
        case "design": return "pencil.and.outline"
        case "development", "programming", "code": return "chevron.left.forwardslash.chevron.right"
        case "marketing": return "megaphone.fill"
        case "business": return "briefcase.fill"
        case "data", "analytics": return "chart.bar.fill"
        case "photography": return "camera.fill"
        case "music": return "music.note"
        default: return "book.fill"
        }
    }
    
    // MARK: - View
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // MARK: - Image Header with Gradient Overlay
            ZStack(alignment: .topLeading) {
                // Course Image
                let imageName = CourseImageHelper.getCourseImage(courseCoverUrl: course.courseCoverUrl, category: course.category)
                
                if let uiImage = UIImage(named: imageName) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 160)
                        .clipped()
                } else {
                    // Fallback gradient
                    LinearGradient(
                        colors: [categoryColor.opacity(0.6), categoryColor.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .overlay(
                        Image(systemName: categoryIcon)
                            .font(.system(size: 50, weight: .semibold))
                            .foregroundColor(.white.opacity(0.3))
                    )
                    .frame(height: 160)
                }
                
                // Gradient Overlay
                LinearGradient(
                    colors: [Color.clear, Color.black.opacity(0.7)],
                    startPoint: .center,
                    endPoint: .bottom
                )
                .frame(height: 160)
                
                // Popular Badge
                if course.enrollmentCount > 100 {
                    PopularBadge()
                        .padding(12)
                }
                
                // Course Title on Image
                VStack {
                    Spacer()
                    Text(course.title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                }
                .frame(height: 160)
            }
            .cornerRadius(16, corners: [.topLeft, .topRight])
            
            // MARK: - Content Section
            VStack(alignment: .leading, spacing: 12) {
                // Rating Row
                if let rating = course.ratingAvg, rating > 0 {
                    StarRatingDisplayView(
                        rating: rating,
                        size: 14,
                        ratingCount: course.ratingCount
                    )
                }
                
                // Description
                Text(course.description)
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.secondaryText)
                    .lineLimit(2)
                
                // Metadata Row
                HStack(spacing: 12) {
                    Label(course.category, systemImage: "folder.fill")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(categoryColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(categoryColor.opacity(0.12))
                        .cornerRadius(6)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "list.bullet")
                            .font(.system(size: 11))
                        Text("\(course.modules.count) modules")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(AppTheme.secondaryText)
                }
            }
            .padding(16)
            
            // MARK: - Footer Section
            HStack {
                if isEnrolled {
                    HStack(spacing: 12) {
                        MiniProgressRing(progress: progress)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            if progress >= 1.0 {
                                Label("Completed", systemImage: "checkmark.seal.fill")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(AppTheme.successGreen)
                                
                                Text("Certificate ready!")
                                    .font(.system(size: 11))
                                    .foregroundColor(AppTheme.secondaryText)
                            } else {
                                Text("In Progress")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(AppTheme.primaryText)
                                
                                Text("\(Int(progress * 100))% complete")
                                    .font(.system(size: 11))
                                    .foregroundColor(AppTheme.secondaryText)
                            }
                        }
                    }
                    
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppTheme.secondaryText)
                    
                } else {
                    VStack(alignment: .leading, spacing: 2) {
                        if let price = course.price, price > 0 {
                            Text(price.formatted(.currency(code: "INR")))
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(AppTheme.primaryText)
                        } else {
                            Text("Free")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(AppTheme.successGreen)
                        }
                    }
                    
                    Spacer()
                    
                    Button {
                        if let price = course.price, price > 0 {
                            showPaymentRequired = true
                        } else {
                            Task {
                                isEnrolling = true
                                await onEnroll()
                                withAnimation {
                                    showSuccess = true
                                }
                                try? await Task.sleep(nanoseconds: 1_200_000_000)
                                showSuccess = false
                                isEnrolling = false
                            }
                        }
                    } label: {
                        Group {
                            if showSuccess {
                                Label("Enrolled!", systemImage: "checkmark.circle.fill")
                            } else if isEnrolling {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Enroll")
                            }
                        }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 110, height: 40)
                        .background(
                            showSuccess ?
                            AppTheme.successGreen : AppTheme.primaryBlue
                        )
                        .cornerRadius(10)
                    }
                    .disabled(isEnrolling)
                }
            }
            .padding(16)
            .background(
                AppTheme.secondaryGroupedBackground.opacity(0.3)
            )
            .cornerRadius(16, corners: [.bottomLeft, .bottomRight])
        }
        .background(AppTheme.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.4 : 0.15),
                radius: 12,
                x: 0,
                y: 6)
        .alert("Payment Required", isPresented: $showPaymentRequired) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please open the course details to purchase this course.")
        }
    }
}
