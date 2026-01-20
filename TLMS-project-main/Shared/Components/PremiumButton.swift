//
//  PremiumButton.swift
//  TLMS-project-main
//
//  Premium button with haptic feedback, loading states, and animations
//

import SwiftUI

struct PremiumButton: View {
    let title: String
    let icon: String?
    let gradient: LinearGradient
    let isLoading: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    init(
        title: String,
        icon: String? = nil,
        gradient: LinearGradient = AppTheme.oceanGradient,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.gradient = gradient
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            guard !isLoading && !isDisabled else { return }
            
            // Haptic feedback
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            
            action()
        }) {
            HStack(spacing: 12) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                } else {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .semibold))
                    }
                    
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                Group {
                    if isDisabled {
                        Color.gray.opacity(0.3)
                    } else {
                        gradient
                    }
                }
            )
            .cornerRadius(AppTheme.mediumCornerRadius)
            .shadow(
                color: isDisabled ? .clear : AppTheme.primaryBlue.opacity(0.4),
                radius: 12,
                x: 0,
                y: 6
            )
            .scaleEffect(isPressed ? 0.96 : 1.0)
        }
        .disabled(isLoading || isDisabled)
        .pressEvents(
            onPress: { isPressed = true },
            onRelease: { isPressed = false }
        )
        .animation(AppTheme.quickAnimation, value: isPressed)
    }
}

// MARK: - Secondary Button

struct SecondaryButton: View {
    let title: String
    let icon: String?
    let color: Color
    let isLoading: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    init(
        title: String,
        icon: String? = nil,
        color: Color = AppTheme.primaryBlue,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.color = color
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            guard !isLoading && !isDisabled else { return }
            
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            
            action()
        }) {
            HStack(spacing: 12) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: color))
                        .scaleEffect(0.9)
                } else {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .semibold))
                    }
                    
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                }
            }
            .foregroundColor(isDisabled ? .gray : color)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                isDisabled ? Color.gray.opacity(0.1) : color.opacity(0.1)
            )
            .cornerRadius(AppTheme.mediumCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.mediumCornerRadius)
                    .stroke(isDisabled ? Color.gray.opacity(0.3) : color, lineWidth: 2)
            )
        }
        .disabled(isLoading || isDisabled)
        .pressableScale()
    }
}

// MARK: - Press Events Helper

extension View {
    func pressEvents(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        self.simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in onPress() }
                .onEnded { _ in onRelease() }
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        PremiumButton(
            title: "Enroll Now",
            icon: "checkmark.circle.fill",
            action: {}
        )
        
        PremiumButton(
            title: "Processing...",
            isLoading: true,
            action: {}
        )
        
        PremiumButton(
            title: "Disabled",
            isDisabled: true,
            action: {}
        )
        
        SecondaryButton(
            title: "View Details",
            icon: "arrow.right",
            action: {}
        )
        
        PremiumButton(
            title: "Success",
            gradient: AppTheme.successGradient,
            action: {}
        )
    }
    .padding()
    .background(AppTheme.groupedBackground)
}
