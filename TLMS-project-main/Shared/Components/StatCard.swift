//
//  StatCard.swift
//  TLMS-project-main
//

import SwiftUI

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(AppTheme.secondaryText)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .fill(AppTheme.secondaryGroupedBackground)
                .shadow(
                    color: color.opacity(colorScheme == .dark ? 0.3 : 0.15),
                    radius: 15,
                    y: 5
                )
        )
    }
}

struct DeadlineCard: View {
    let deadline: CourseDeadline
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .foregroundColor(AppTheme.primaryBlue)
                
                Spacer()
                
                Text(timeRemainingText(from: deadline.deadlineAt))
                    .font(.caption.bold())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppTheme.primaryBlue.opacity(0.12))
                    .foregroundColor(AppTheme.primaryBlue)
                    .cornerRadius(10)
            }
            
            Text(deadline.title)
                .font(.headline)
                .foregroundColor(AppTheme.primaryText)
                .lineLimit(2)
            
            Text(deadline.deadlineAt.formatted(date: .abbreviated, time: .shortened))
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(14)
        .frame(width: 240)
        .background(AppTheme.secondaryGroupedBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private func timeRemainingText(from date: Date) -> String {
        let interval = date.timeIntervalSinceNow
        if interval <= 0 { return "Due" }
        
        let hours = Int(interval / 3600)
        let days = hours / 24
        
        if days >= 1 { return "\(days)d left" }
        if hours >= 1 { return "\(hours)h left" }
        
        let mins = Int(interval / 60)
        return "\(max(mins, 1))m left"
    }
}
