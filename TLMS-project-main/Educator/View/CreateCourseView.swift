//
//  CreateCourseView.swift
//  TLMS-project-main
//
//  Step 1: Basic Course Information
//

import SwiftUI
import _PhotosUI_SwiftUI

struct CreateCourseView: View {
    @ObservedObject var viewModel: CourseCreationViewModel
    @Environment(\.dismiss) var dismiss
    
    // Categories for the dropdown
    let categories = ["Development", "Business", "Design", "Marketing", "Lifestyle", "Photography", "Health & Fitness", "Music", "Teaching & Academics"]
    
    var body: some View {
        ZStack {
            // Background
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Course Details")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(AppTheme.primaryText)
                        
                        Text("Let's set up the foundation of your course. You can always edit these details later.")
                            .font(.body)
                            .foregroundColor(AppTheme.secondaryText)
                            .lineSpacing(4)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    
                    VStack(spacing: 28) {
                        // MARK: - Course Title
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Course Title", systemImage: "textformat")
                                .font(.headline)
                                .foregroundColor(AppTheme.primaryText)
                            
                            TextField("e.g. Advanced iOS Architecture", text: $viewModel.newCourse.title)
                                .font(.body)
                                .padding(16)
                                .background(AppTheme.secondaryGroupedBackground)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.secondary.opacity(0.1), lineWidth: 1)
                                )
                        }
                        
                        // MARK: - Category & Level Row
                        HStack(spacing: 16) {
                            // Category
                            VStack(alignment: .leading, spacing: 10) {
                                Label("Category", systemImage: "folder")
                                    .font(.headline)
                                    .foregroundColor(AppTheme.primaryText)
                                
                                Menu {
                                    ForEach(categories, id: \.self) { category in
                                        Button(action: { viewModel.newCourse.category = category }) {
                                            Text(category)
                                            if viewModel.newCourse.category == category {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(viewModel.newCourse.category.isEmpty ? "Select" : viewModel.newCourse.category)
                                            .foregroundColor(viewModel.newCourse.category.isEmpty ? AppTheme.secondaryText : AppTheme.primaryText)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .font(.caption.bold())
                                            .foregroundColor(AppTheme.secondaryText)
                                    }
                                    .padding(16)
                                    .background(AppTheme.secondaryGroupedBackground)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.secondary.opacity(0.1), lineWidth: 1)
                                    )
                                }
                            }
                            
                            // Level
                            VStack(alignment: .leading, spacing: 10) {
                                Label("Level", systemImage: "chart.bar")
                                    .font(.headline)
                                    .foregroundColor(AppTheme.primaryText)
                                
                                Menu {
                                    ForEach(CourseLevel.allCases, id: \.self) { level in
                                        Button(action: { viewModel.newCourse.level = level }) {
                                            Text(level.rawValue)
                                            if viewModel.newCourse.level == level {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(viewModel.newCourse.level.rawValue)
                                            .foregroundColor(AppTheme.primaryText)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .font(.caption.bold())
                                            .foregroundColor(AppTheme.secondaryText)
                                    }
                                    .padding(16)
                                    .background(AppTheme.secondaryGroupedBackground)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.secondary.opacity(0.1), lineWidth: 1)
                                    )
                                }
                            }
                        }
                        
                        // MARK: - Price Row
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Pricing (₹)", systemImage: "indianrupeesign.circle")
                                .font(.headline)
                                .foregroundColor(AppTheme.primaryText)
                            
                            TextField("Enter amount (0 for Free)", value: $viewModel.newCourse.price, format: .number)
                                .keyboardType(.decimalPad)
                                .font(.body.bold())
                                .padding(16)
                                .background(AppTheme.secondaryGroupedBackground)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.secondary.opacity(0.1), lineWidth: 1)
                                )
                                .foregroundColor(AppTheme.primaryBlue)
                        }
                        
                        // MARK: - Description
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Description", systemImage: "doc.text")
                                .font(.headline)
                                .foregroundColor(AppTheme.primaryText)
                            
                            TextEditor(text: $viewModel.newCourse.description)
                                .frame(minHeight: 120)
                                .padding(12)
                                .background(AppTheme.secondaryGroupedBackground)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.secondary.opacity(0.1), lineWidth: 1)
                                )
                        }
                        
                        // MARK: - Cover Image Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Course Cover", systemImage: "photo")
                                .font(.headline)
                                .foregroundColor(AppTheme.primaryText)
                            
                            ZStack(alignment: .bottomTrailing) {
                                Group {
                                    if let data = viewModel.selectedImageData, let uiImage = UIImage(data: data) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(height: 180)
                                            .cornerRadius(16)
                                            .clipped()
                                    } else {
                                        let imageName = CourseImageHelper.getCourseImage(courseCoverUrl: viewModel.newCourse.courseCoverUrl, category: viewModel.newCourse.category)
                                        
                                        if let uiImage = UIImage(named: imageName) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(height: 180)
                                                .cornerRadius(16)
                                                .clipped()
                                        } else {
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(AppTheme.primaryBlue.opacity(0.1))
                                                .frame(height: 180)
                                                .overlay(
                                                    Image(systemName: "photo.on.rectangle.angled")
                                                        .font(.largeTitle)
                                                        .foregroundColor(AppTheme.primaryBlue.opacity(0.4))
                                                )
                                        }
                                    }
                                }
                                
                                HStack(spacing: 8) {
                                    PhotosPicker(selection: $viewModel.selectedItem, matching: .images) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "photo.badge.plus")
                                            Text("Pick from Photos")
                                        }
                                        .font(.caption.bold())
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(.ultraThinMaterial)
                                        .cornerRadius(20)
                                    }
                                    
                                    if viewModel.selectedImageData == nil {
                                        HStack(spacing: 4) {
                                            Image(systemName: "sparkles")
                                            Text("AI Recommended")
                                        }
                                        .font(.caption.bold())
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(.ultraThinMaterial)
                                        .cornerRadius(20)
                                    }
                                }
                                .padding(12)
                            }
                            
                            Text(viewModel.selectedImageData != nil ? "Your custom cover image is set." : "Your cover image is automatically optimized based on your category, or you can pick your own.")
                                .font(.caption)
                                .foregroundColor(AppTheme.secondaryText)
                                .italic()
                        }
                    }
                    .padding(24)
                    .background(AppTheme.cardBackground)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 24)
                    
                    // MARK: - Continue Button
                    NavigationLink(destination: CourseStructureView(viewModel: viewModel)) {
                        HStack {
                            Text("Next: Structure Course")
                                .font(.headline)
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(viewModel.isCourseInfoValid ? AppTheme.primaryBlue : Color.gray.opacity(0.3))
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(color: viewModel.isCourseInfoValid ? AppTheme.primaryBlue.opacity(0.3) : .clear, radius: 8, y: 4)
                    }
                    .disabled(!viewModel.isCourseInfoValid)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "xmark.circle.fill")
                        Text("Close")
                    }
                    .font(.subheadline.bold())
                    .foregroundColor(AppTheme.secondaryText)
                }
            }
        }
        .overlay {
            if viewModel.isLoadingCourse {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    ProgressView("Loading course...")
                        .padding()
                        .background(AppTheme.secondaryGroupedBackground)
                        .cornerRadius(AppTheme.cornerRadius)
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        CreateCourseView(viewModel: CourseCreationViewModel(educatorID: UUID()))
    }
}
