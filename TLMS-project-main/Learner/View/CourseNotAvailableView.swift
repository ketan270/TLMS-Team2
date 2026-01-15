//
//  CourseNotAvailableView.swift
//  TLMS-project-main
//
//  Displayed when a course has been removed or is unavailable.
//

import SwiftUI

struct CourseNotAvailableView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.warningOrange)
            
            VStack(spacing: 12) {
                Text("Course Not Available")
                    .font(.title2.bold())
                    .foregroundColor(AppTheme.primaryText)
                
                Text("This course is no longer available. It may have been removed or is undergoing review.")
                    .font(.body)
                    .foregroundColor(AppTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Button(action: {
                dismiss()
            }) {
                Text("Go Back")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(AppTheme.primaryBlue)
                    .cornerRadius(AppTheme.cornerRadius)
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .padding()
        .background(AppTheme.groupedBackground)
    }
}

#Preview {
    CourseNotAvailableView()
}
