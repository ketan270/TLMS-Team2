//
//  AnalyticsTimeFilter.swift
//  TLMS-project-main
//
//  Enum representing time periods for analytics filtering.
//

import Foundation

enum AnalyticsTimeFilter: String, CaseIterable, Identifiable {
    case last7Days = "Last 7 Days"
    case last30Days = "Last 30 Days"
    case last3Months = "Last 3 Months"
    case allTime = "All Time"
    
    var id: String { rawValue }
    
    func isDateInPeriod(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let now = Date()
        
        switch self {
        case .last7Days:
            guard let start = calendar.date(byAdding: .day, value: -7, to: now) else { return false }
            return date >= start
        case .last30Days:
            guard let start = calendar.date(byAdding: .day, value: -30, to: now) else { return false }
            return date >= start
        case .last3Months:
            guard let start = calendar.date(byAdding: .month, value: -3, to: now) else { return false }
            return date >= start
        case .allTime:
            return true
        }
    }
}
