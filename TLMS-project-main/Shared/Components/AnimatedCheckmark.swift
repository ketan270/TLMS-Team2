//
//  AnimatedCheckmark.swift
//  TLMS-project-main
//
//  Animated checkmark for success states with optional confetti
//

import SwiftUI

struct AnimatedCheckmark: View {
    let size: CGFloat
    let color: Color
    let showConfetti: Bool
    
    @State private var checkmarkProgress: CGFloat = 0
    @State private var scale: CGFloat = 0
    @State private var rotation: Double = -45
    @State private var showParticles = false
    
    init(
        size: CGFloat = 80,
        color: Color = AppTheme.successGreen,
        showConfetti: Bool = false
    ) {
        self.size = size
        self.color = color
        self.showConfetti = showConfetti
    }
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(color.opacity(0.15))
                .frame(width: size, height: size)
                .scaleEffect(scale)
            
            // Checkmark
            CheckmarkShape(progress: checkmarkProgress)
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: size * 0.1,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
                .frame(width: size * 0.5, height: size * 0.5)
                .rotationEffect(.degrees(rotation))
            
            // Confetti particles
            if showConfetti && showParticles {
                ForEach(0..<12) { index in
                    ConfettiParticle(
                        color: confettiColors[index % confettiColors.count],
                        angle: Double(index) * 30,
                        distance: size * 0.8
                    )
                }
            }
        }
        .onAppear {
            animateCheckmark()
        }
    }
    
    private func animateCheckmark() {
        // Scale in background
        withAnimation(AppTheme.springAnimation.delay(0.1)) {
            scale = 1.0
        }
        
        // Rotate and draw checkmark
        withAnimation(AppTheme.springAnimation.delay(0.2)) {
            rotation = 0
        }
        
        withAnimation(Animation.easeOut(duration: 0.4).delay(0.3)) {
            checkmarkProgress = 1.0
        }
        
        // Show confetti
        if showConfetti {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    showParticles = true
                }
            }
        }
    }
    
    private let confettiColors: [Color] = [
        .red, .orange, .yellow, .green, .blue, .purple, .pink
    ]
}

// MARK: - Checkmark Shape

struct CheckmarkShape: Shape {
    var progress: CGFloat
    
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        
        // Checkmark path
        let point1 = CGPoint(x: width * 0.2, y: height * 0.5)
        let point2 = CGPoint(x: width * 0.45, y: height * 0.75)
        let point3 = CGPoint(x: width * 0.9, y: height * 0.25)
        
        path.move(to: point1)
        
        if progress > 0 {
            let firstSegmentProgress = min(progress * 2, 1.0)
            let firstSegmentEnd = CGPoint(
                x: point1.x + (point2.x - point1.x) * firstSegmentProgress,
                y: point1.y + (point2.y - point1.y) * firstSegmentProgress
            )
            path.addLine(to: firstSegmentEnd)
            
            if progress > 0.5 {
                let secondSegmentProgress = (progress - 0.5) * 2
                let secondSegmentEnd = CGPoint(
                    x: point2.x + (point3.x - point2.x) * secondSegmentProgress,
                    y: point2.y + (point3.y - point2.y) * secondSegmentProgress
                )
                path.addLine(to: secondSegmentEnd)
            }
        }
        
        return path
    }
}

// MARK: - Confetti Particle

struct ConfettiParticle: View {
    let color: Color
    let angle: Double
    let distance: CGFloat
    
    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 1
    @State private var rotation: Double = 0
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 8, height: 8)
            .offset(
                x: cos(angle * .pi / 180) * offset,
                y: sin(angle * .pi / 180) * offset
            )
            .opacity(opacity)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation(Animation.easeOut(duration: 0.8)) {
                    offset = distance
                    opacity = 0
                    rotation = Double.random(in: 0...360)
                }
            }
    }
}

// MARK: - Success Animation View

struct SuccessAnimationView: View {
    let title: String
    let message: String
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            AnimatedCheckmark(size: 100, showConfetti: true)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.title2.bold())
                    .foregroundColor(AppTheme.primaryText)
                
                Text(message)
                    .font(.body)
                    .foregroundColor(AppTheme.secondaryText)
                    .multilineTextAlignment(.center)
            }
            .fadeInOnAppear(delay: 0.6)
            
            PremiumButton(
                title: "Continue",
                gradient: AppTheme.successGradient,
                action: onDismiss
            )
            .fadeInOnAppear(delay: 0.8)
        }
        .padding(32)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.cornerRadius)
        .shadow(
            color: AppTheme.elevatedShadow.color,
            radius: AppTheme.elevatedShadow.radius,
            x: AppTheme.elevatedShadow.x,
            y: AppTheme.elevatedShadow.y
        )
    }
}

#Preview {
    ZStack {
        AppTheme.groupedBackground
            .ignoresSafeArea()
        
        VStack(spacing: 40) {
            AnimatedCheckmark()
            
            AnimatedCheckmark(size: 60, color: AppTheme.primaryBlue)
            
            SuccessAnimationView(
                title: "Enrollment Successful!",
                message: "You're all set to start learning",
                onDismiss: {}
            )
            .padding()
        }
    }
}
