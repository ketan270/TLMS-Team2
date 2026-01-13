//
//  AdminAnalyticsView.swift
//  TLMS-project-main
//
//  Displaying charts for Admin Analytics.
//

import SwiftUI
import Charts

struct AdminAnalyticsView: View {
    let totalRevenue: Double
    let adminRevenue: Double
    let educatorRevenue: Double
    let totalLearners: Int
    let totalEducators: Int
    var showRevenue: Bool = true
    
    // Data Models for Charts
    struct RevenueSegment: Identifiable {
        let id = UUID()
        let name: String
        let value: Double
        let color: Color
    }
    
    struct UserSegment: Identifiable {
        let id = UUID()
        let name: String
        let count: Int
        let color: Color
    }
    
    var revenueData: [RevenueSegment] {
        [
            RevenueSegment(name: "Admin", value: adminRevenue, color: AppTheme.primaryBlue),
            RevenueSegment(name: "Educators", value: educatorRevenue, color: .purple)
        ]
    }
    
    var userData: [UserSegment] {
        [
            UserSegment(name: "Learners", count: totalLearners, color: AppTheme.successGreen),
            UserSegment(name: "Educators", count: totalEducators, color: .orange)
        ]
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            HStack {
                Text("Analytics")
                    .font(.title2.bold())
                Spacer()
            }
            .padding(.horizontal)
            
            // Charts Grid (Adaptive)
            if #available(iOS 17.0, *) {
                VStack(spacing: 20) {
                    // Revenue Chart
                    ChartCard(title: "Revenue Distribution") {
                        if showRevenue {
                            Chart(revenueData) { segment in
                                SectorMark(
                                    angle: .value("Revenue", segment.value),
                                    innerRadius: .ratio(0.5),
                                    angularInset: 1.5
                                )
                                .foregroundStyle(segment.color)
                                .annotation(position: .overlay) {
                                    Text(segment.value.formatted(.currency(code: "INR").precision(.fractionLength(0))))
                                        .font(.caption.bold())
                                        .foregroundColor(.white)
                                }
                            }
                        } else {
                            VStack(spacing: 12) {
                                Image(systemName: "nosign")
                                    .font(.largeTitle)
                                    .foregroundColor(.secondary.opacity(0.3))
                                Text("Revenue data will be available once pricing is enabled")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    } legend: {
                        if showRevenue {
                            HStack(spacing: 16) {
                                LegendItem(color: AppTheme.primaryBlue, label: "Admin")
                                LegendItem(color: .purple, label: "Educators")
                            }
                        }
                    }
                    
                    // User Chart
                    ChartCard(title: "User Distribution") {
                        Chart(userData) { segment in
                            SectorMark(
                                angle: .value("Count", segment.count),
                                innerRadius: .ratio(0.5),
                                angularInset: 1.5
                            )
                            .foregroundStyle(segment.color)
                            .annotation(position: .overlay) {
                                Text("\(segment.count)")
                                    .font(.caption.bold())
                                    .foregroundColor(.white)
                            }
                        }
                    } legend: {
                        HStack(spacing: 16) {
                            LegendItem(color: AppTheme.successGreen, label: "Learners")
                            LegendItem(color: .orange, label: "Educators")
                        }
                    }
                }
                .padding(.horizontal)
            } else {
                // Fallback for iOS 16 (Using Bar Charts as SectorMark is iOS 17+)
                VStack(spacing: 20) {
                    ChartCard(title: "Revenue Distribution") {
                        if showRevenue {
                            Chart(revenueData) { segment in
                                BarMark(
                                    x: .value("Revenue", segment.value),
                                    stacking: .normalized
                                )
                                .foregroundStyle(segment.color)
                            }
                            .chartXAxis(.hidden)
                        } else {
                            VStack(spacing: 12) {
                                Image(systemName: "nosign")
                                    .font(.largeTitle)
                                    .foregroundColor(.secondary.opacity(0.3))
                                Text("Revenue data will be available once pricing is enabled")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    } legend: {
                        if showRevenue {
                            HStack {
                                LegendItem(color: AppTheme.primaryBlue, label: "Admin")
                                LegendItem(color: .purple, label: "Educators")
                            }
                        }
                    }
                    
                    ChartCard(title: "User Distribution") {
                        Chart(userData) { segment in
                            BarMark(
                                x: .value("Count", segment.count),
                                stacking: .normalized
                            )
                            .foregroundStyle(segment.color)
                        }
                        .chartXAxis(.hidden)
                    } legend: {
                        HStack {
                            LegendItem(color: AppTheme.successGreen, label: "Learners")
                            LegendItem(color: .orange, label: "Educators")
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// Helper Components

struct ChartCard<Content: View, Legend: View>: View {
    let title: String
    @ViewBuilder let content: Content
    @ViewBuilder let legend: Legend
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
            
            content
                .frame(height: 200)
            
            legend
                .font(.caption)
                .frame(maxWidth: .infinity)
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
}

struct LegendItem: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .foregroundColor(.secondary)
        }
    }
}
