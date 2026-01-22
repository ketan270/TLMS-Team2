//
//  CategoryCourseCard.swift
//  TLMS-project-main
//
//  Created by Chehak on 16/01/26.
//

import Foundation
import SwiftUI

struct CategoryCourseCard: View {
    let course: Course
    let isEnrolled: Bool
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            // MARK: - Left: Category Icon
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(course.categoryColor.opacity(0.1))
                    .frame(width: 76, height: 76)
                
                Image(systemName: course.categoryIcon)
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(course.categoryColor)
            }
            .shadow(color: course.categoryColor.opacity(0.15), radius: 6, x: 0, y: 3)
            
            // MARK: - Middle: Course Info
            VStack(alignment: .leading, spacing: 6) {
                Text(course.title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.primaryText)
                    .lineLimit(1)
                
                Text(course.description)
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.secondaryText)
                    .lineLimit(2)
                
                HStack(spacing: 8) {
                    // Category Badge
                    HStack(spacing: 4) {
                        Image(systemName: "folder.fill")
                            .font(.system(size: 10))
                        Text(course.category)
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundColor(course.categoryColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(course.categoryColor.opacity(0.12))
                    .cornerRadius(8)
                    
                    // Module Count
                    HStack(spacing: 4) {
                        Image(systemName: "list.bullet")
                            .font(.system(size: 10))
                        Text("\(course.modules.count) modules")
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundColor(AppTheme.secondaryText)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(AppTheme.secondaryGroupedBackground)
                    .cornerRadius(8)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            // MARK: - Right: Action/Price Pill
            VStack(alignment: .center, spacing: 6) {
                if isEnrolled {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 26))
                        .foregroundColor(AppTheme.primaryBlue)
                } else {
                    if let price = course.price, price > 0 {
                        Text(price.formatted(.currency(code: "INR")))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppTheme.primaryText)
                    } else {
                        Text("Free")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(AppTheme.successGreen)
                    }
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(AppTheme.secondaryText.opacity(0.6))
            }
            .frame(width: 100, height: 74)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(uiColor: .systemBackground))
                    .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.08), radius: 10, x: 0, y: 4)
            )
        }
        .padding(.vertical, 8)
        .background(Color.clear)
    }
}
