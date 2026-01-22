//
//  EducatorDashboardComponents.swift
//  TLMS-project-main
//

import SwiftUI

// MARK: - Empty Courses Card

struct EmptyCoursesCard: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed.fill")
                .font(.system(size: 50))
                .foregroundStyle(AppTheme.secondaryText.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("No courses yet")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(AppTheme.primaryText)
                
                Text("Create your first course to start teaching")
                    .font(.body)
                    .foregroundColor(AppTheme.secondaryText)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(AppTheme.secondaryGroupedBackground)
        .cornerRadius(AppTheme.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Approval Banners

struct PendingApprovalBanner: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.fill")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            VStack(spacing: 8) {
                Text("Account Pending Approval")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("Your educator account is awaiting admin approval. You'll be able to create courses once approved.")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(30)
        .background(.ultraThinMaterial)
        .cornerRadius(24)
        .shadow(color: .orange.opacity(0.2), radius: 15, y: 5)
    }
}

struct RejectedBanner: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
            VStack(spacing: 8) {
                Text("Account Rejected")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("Your educator account has been rejected. Please contact support for more information.")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(30)
        .background(.ultraThinMaterial)
        .cornerRadius(24)
        .shadow(color: .red.opacity(0.2), radius: 15, y: 5)
    }
}
