//
//  AppTheme.swift
//  TLMS-project-main
//
//  Premium Design System with sophisticated animations and modern aesthetics
//

import SwiftUI

struct AppTheme {
    // MARK: - Premium Color Palette (HSL-based for better dark mode)
    
    // Primary Brand Colors - Sophisticated Blue Palette
    static let primaryBlue = Color(hue: 0.58, saturation: 0.85, brightness: 0.95)
    static let primaryBlueDark = Color(hue: 0.58, saturation: 0.90, brightness: 0.75)
    static let primaryAccent = primaryBlue
    
    // Vibrant Accent Colors
    static let accentPurple = Color(hue: 0.75, saturation: 0.70, brightness: 0.90)
    static let accentCyan = Color(hue: 0.52, saturation: 0.75, brightness: 0.92)
    static let accentTeal = Color(hue: 0.48, saturation: 0.65, brightness: 0.88)
    
    // Semantic Colors
    static let successGreen = Color(hue: 0.33, saturation: 0.75, brightness: 0.65)
    static let warningOrange = Color(hue: 0.08, saturation: 0.85, brightness: 0.95)
    static let errorRed = Color(hue: 0.98, saturation: 0.85, brightness: 0.90)
    static let infoBlue = Color(hue: 0.58, saturation: 0.70, brightness: 0.95)
    
    // Neutral Colors (Adaptive)
    static let background = Color(uiColor: .systemBackground)
    static let secondaryBackground = Color(uiColor: .secondarySystemBackground)
    static let groupedBackground = Color(uiColor: .systemGroupedBackground)
    static let secondaryGroupedBackground = Color(uiColor: .secondarySystemGroupedBackground)
    static let cardBackground = Color(uiColor: .secondarySystemGroupedBackground)
    
    // Text Colors
    static let primaryText = Color.primary
    static let secondaryText = Color.secondary
    static let tertiaryText = Color(uiColor: .tertiaryLabel)
    
    // MARK: - Premium Gradients
    
    static var oceanGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(hue: 0.58, saturation: 0.85, brightness: 0.95),
                Color(hue: 0.52, saturation: 0.75, brightness: 0.92),
                Color(hue: 0.48, saturation: 0.65, brightness: 0.88)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var sunsetGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(hue: 0.08, saturation: 0.85, brightness: 0.95),
                Color(hue: 0.98, saturation: 0.85, brightness: 0.90),
                Color(hue: 0.75, saturation: 0.70, brightness: 0.90)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var twilightGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(hue: 0.75, saturation: 0.70, brightness: 0.90),
                Color(hue: 0.58, saturation: 0.85, brightness: 0.95),
                Color(hue: 0.52, saturation: 0.75, brightness: 0.92)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var successGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(hue: 0.33, saturation: 0.75, brightness: 0.65),
                Color(hue: 0.40, saturation: 0.70, brightness: 0.75)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    static var subtleGradient: LinearGradient {
        LinearGradient(
            colors: [
                groupedBackground,
                secondaryGroupedBackground,
                groupedBackground
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Layout Constants
    
    static let cornerRadius: CGFloat = 16
    static let mediumCornerRadius: CGFloat = 12
    static let smallCornerRadius: CGFloat = 8
    static let cardPadding: CGFloat = 16
    static let sectionSpacing: CGFloat = 24
    
    // MARK: - Shadow Styles
    
    static let elevatedShadow = Shadow(
        color: Color.black.opacity(0.12),
        radius: 12,
        x: 0,
        y: 6
    )
    
    static let cardShadow = Shadow(
        color: Color.black.opacity(0.08),
        radius: 8,
        x: 0,
        y: 4
    )
    
    static let subtleShadow = Shadow(
        color: Color.black.opacity(0.05),
        radius: 4,
        x: 0,
        y: 2
    )
    
    // MARK: - Animation Constants
    
    static let springAnimation = Animation.spring(
        response: 0.4,
        dampingFraction: 0.7,
        blendDuration: 0.3
    )
    
    static let smoothAnimation = Animation.easeInOut(duration: 0.3)
    static let quickAnimation = Animation.easeOut(duration: 0.2)
    static let slowAnimation = Animation.easeInOut(duration: 0.5)
}

// MARK: - Shadow Helper
struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - Premium View Modifiers

extension View {
    // MARK: - Card Styles
    
    func glassmorphicCard() -> some View {
        self
            .background(.ultraThinMaterial)
            .cornerRadius(AppTheme.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.3),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: AppTheme.cardShadow.color,
                radius: AppTheme.cardShadow.radius,
                x: AppTheme.cardShadow.x,
                y: AppTheme.cardShadow.y
            )
    }
    
    func premiumCard() -> some View {
        self
            .background(AppTheme.cardBackground)
            .cornerRadius(AppTheme.cornerRadius)
            .shadow(
                color: AppTheme.elevatedShadow.color,
                radius: AppTheme.elevatedShadow.radius,
                x: AppTheme.elevatedShadow.x,
                y: AppTheme.elevatedShadow.y
            )
    }
    
    func standardCardStyle() -> some View {
        self
            .background(AppTheme.cardBackground)
            .cornerRadius(AppTheme.mediumCornerRadius)
            .shadow(
                color: AppTheme.subtleShadow.color,
                radius: AppTheme.subtleShadow.radius,
                x: AppTheme.subtleShadow.x,
                y: AppTheme.subtleShadow.y
            )
    }
    
    // MARK: - Button Styles
    
    func premiumButton(gradient: LinearGradient = AppTheme.oceanGradient) -> some View {
        self
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(.white)
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity)
            .background(gradient)
            .cornerRadius(AppTheme.mediumCornerRadius)
            .shadow(
                color: AppTheme.primaryBlue.opacity(0.4),
                radius: 12,
                x: 0,
                y: 6
            )
    }
    
    func primaryButtonStyle() -> some View {
        self.premiumButton()
    }
    
    func secondaryButtonStyle() -> some View {
        self
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(AppTheme.primaryBlue)
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity)
            .background(AppTheme.cardBackground)
            .cornerRadius(AppTheme.mediumCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.mediumCornerRadius)
                    .stroke(AppTheme.primaryBlue, lineWidth: 2)
            )
    }
    
    func outlineButton(color: Color = AppTheme.primaryBlue) -> some View {
        self
            .font(.system(size: 15, weight: .medium))
            .foregroundColor(color)
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background(color.opacity(0.1))
            .cornerRadius(AppTheme.smallCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                    .stroke(color.opacity(0.5), lineWidth: 1.5)
            )
    }
    
    // MARK: - Interactive Animations
    
    func pressableScale() -> some View {
        self.buttonStyle(PressableScaleButtonStyle())
    }
    
    func shimmerEffect() -> some View {
        self.modifier(ShimmerModifier())
    }
    
    func fadeInOnAppear(delay: Double = 0) -> some View {
        self.modifier(FadeInModifier(delay: delay))
    }
    
    func slideInFromBottom(delay: Double = 0) -> some View {
        self.modifier(SlideInModifier(delay: delay))
    }
}

// MARK: - Custom Button Style with Scale Animation

struct PressableScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(AppTheme.quickAnimation, value: configuration.isPressed)
    }
}

// MARK: - Shimmer Loading Effect

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0),
                        Color.white.opacity(0.3),
                        Color.white.opacity(0)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .rotationEffect(.degrees(30))
                .offset(x: phase)
                .mask(content)
            )
            .onAppear {
                withAnimation(
                    Animation.linear(duration: 1.5)
                        .repeatForever(autoreverses: false)
                ) {
                    phase = 400
                }
            }
    }
}

// MARK: - Fade In Animation

struct FadeInModifier: ViewModifier {
    let delay: Double
    @State private var opacity: Double = 0
    
    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .onAppear {
                withAnimation(AppTheme.smoothAnimation.delay(delay)) {
                    opacity = 1
                }
            }
    }
}

// MARK: - Slide In Animation

struct SlideInModifier: ViewModifier {
    let delay: Double
    @State private var offset: CGFloat = 50
    @State private var opacity: Double = 0
    
    func body(content: Content) -> some View {
        content
            .offset(y: offset)
            .opacity(opacity)
            .onAppear {
                withAnimation(AppTheme.springAnimation.delay(delay)) {
                    offset = 0
                    opacity = 1
                }
            }
    }
}
