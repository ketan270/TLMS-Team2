//
//  ProgressRing.swift
//  TLMS-project-main
//
//  Animated circular progress indicator with gradient stroke
//

import SwiftUI

struct ProgressRing: View {
    let progress: Double // 0.0 to 1.0
    let lineWidth: CGFloat
    let size: CGFloat
    let gradient: LinearGradient
    let showPercentage: Bool
    
    @State private var animatedProgress: Double = 0
    
    init(
        progress: Double,
        lineWidth: CGFloat = 12,
        size: CGFloat = 120,
        gradient: LinearGradient = AppTheme.oceanGradient,
        showPercentage: Bool = true
    ) {
        self.progress = min(max(progress, 0), 1) // Clamp between 0 and 1
        self.lineWidth = lineWidth
        self.size = size
        self.gradient = gradient
        self.showPercentage = showPercentage
    }
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(
                    Color.gray.opacity(0.2),
                    lineWidth: lineWidth
                )
            
            // Progress circle
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    gradient,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
            
            // Percentage text
            if showPercentage {
                VStack(spacing: 4) {
                    Text("\(Int(animatedProgress * 100))%")
                        .font(.system(size: size * 0.25, weight: .bold))
                        .foregroundColor(AppTheme.primaryText)
                    
                    Text("Complete")
                        .font(.system(size: size * 0.12, weight: .medium))
                        .foregroundColor(AppTheme.secondaryText)
                }
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(AppTheme.springAnimation.delay(0.2)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { newValue in
            withAnimation(AppTheme.springAnimation) {
                animatedProgress = newValue
            }
        }
    }
}

// MARK: - Mini Progress Ring (for cards)

struct MiniProgressRing: View {
    let progress: Double
    
    var body: some View {
        ProgressRing(
            progress: progress,
            lineWidth: 6,
            size: 60,
            showPercentage: false
        )
        .overlay(
            Text("\(Int(progress * 100))%")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(AppTheme.primaryText)
        )
    }
}

// MARK: - Linear Progress Bar

struct LinearProgressBar: View {
    let progress: Double
    let height: CGFloat
    let gradient: LinearGradient
    
    @State private var animatedProgress: Double = 0
    
    init(
        progress: Double,
        height: CGFloat = 8,
        gradient: LinearGradient = AppTheme.oceanGradient
    ) {
        self.progress = min(max(progress, 0), 1)
        self.height = height
        self.gradient = gradient
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(Color.gray.opacity(0.2))
                
                // Progress
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(gradient)
                    .frame(width: geometry.size.width * animatedProgress)
            }
        }
        .frame(height: height)
        .onAppear {
            withAnimation(AppTheme.springAnimation.delay(0.1)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { newValue in
            withAnimation(AppTheme.springAnimation) {
                animatedProgress = newValue
            }
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        ProgressRing(progress: 0.75)
        
        MiniProgressRing(progress: 0.6)
        
        VStack(spacing: 8) {
            LinearProgressBar(progress: 0.45)
            LinearProgressBar(progress: 0.80, gradient: AppTheme.successGradient)
        }
        .padding()
    }
    .padding()
    .background(AppTheme.groupedBackground)
}
