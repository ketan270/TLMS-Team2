//
//  SkeletonView.swift
//  TLMS-project-main
//
//  Skeleton loading views with shimmer effect for premium loading states
//

import SwiftUI

struct SkeletonView: View {
    let style: SkeletonStyle
    
    var body: some View {
        Group {
            switch style {
            case .card:
                cardSkeleton
            case .text(let width):
                textSkeleton(width: width)
            case .circle(let size):
                circleSkeleton(size: size)
            case .rectangle(let width, let height):
                rectangleSkeleton(width: width, height: height)
            }
        }
        .shimmerEffect()
    }
    
    private var cardSkeleton: some View {
        VStack(alignment: .leading, spacing: 12) {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 180)
                .cornerRadius(AppTheme.mediumCornerRadius)
            
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 20)
                .frame(maxWidth: .infinity)
                .cornerRadius(4)
            
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 16)
                .frame(maxWidth: 200)
                .cornerRadius(4)
            
            HStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 60, height: 16)
                    .cornerRadius(4)
                
                Spacer()
                
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 80, height: 16)
                    .cornerRadius(4)
            }
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.cornerRadius)
    }
    
    private func textSkeleton(width: CGFloat) -> some View {
        Rectangle()
            .fill(Color.gray.opacity(0.2))
            .frame(width: width, height: 16)
            .cornerRadius(4)
    }
    
    private func circleSkeleton(size: CGFloat) -> some View {
        Circle()
            .fill(Color.gray.opacity(0.2))
            .frame(width: size, height: size)
    }
    
    private func rectangleSkeleton(width: CGFloat, height: CGFloat) -> some View {
        Rectangle()
            .fill(Color.gray.opacity(0.2))
            .frame(width: width, height: height)
            .cornerRadius(AppTheme.smallCornerRadius)
    }
}

enum SkeletonStyle {
    case card
    case text(width: CGFloat)
    case circle(size: CGFloat)
    case rectangle(width: CGFloat, height: CGFloat)
}

// MARK: - Course Card Skeleton

struct CourseCardSkeleton: View {
    var body: some View {
        SkeletonView(style: .card)
    }
}

// MARK: - List Skeleton

struct ListSkeleton: View {
    let count: Int
    
    init(count: Int = 3) {
        self.count = count
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(0..<count, id: \.self) { _ in
                CourseCardSkeleton()
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        CourseCardSkeleton()
        
        HStack(spacing: 12) {
            SkeletonView(style: .circle(size: 60))
            VStack(alignment: .leading, spacing: 8) {
                SkeletonView(style: .text(width: 150))
                SkeletonView(style: .text(width: 100))
            }
        }
        .padding()
    }
    .padding()
    .background(AppTheme.groupedBackground)
}
