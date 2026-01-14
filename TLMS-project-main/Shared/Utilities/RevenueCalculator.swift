//
//  RevenueCalculator.swift
//  TLMS-project-main
//
//  Helper for calculating revenue distribution.
//  Current Model: 20% Admin Commission, 80% Educator Earnings.
//

import Foundation

struct RevenueCalculator {
    static let adminCommissionRate: Double = 0.20
    
    static func calculateSplit(total: Double) -> (admin: Double, educator: Double) {
        let adminShare = total * adminCommissionRate
        let educatorShare = total - adminShare
        return (adminShare, educatorShare)
    }
}
