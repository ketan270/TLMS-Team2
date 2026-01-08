//
//  LessonDetailView.swift
//  TLMS-project-main
//
//  Step 4: Lesson Configuration
//

import SwiftUI

struct LessonDetailView: View {
    @ObservedObject var viewModel: CourseCreationViewModel
    let moduleID: UUID
    let lessonID: UUID
    
    // Derived bindings to edit the model directly
    private var lessonBinding: Binding<Lesson>? {
        guard let moduleIndex = viewModel.newCourse.modules.firstIndex(where: { $0.id == moduleID }),
              let lessonIndex = viewModel.newCourse.modules[moduleIndex].lessons.firstIndex(where: { $0.id == lessonID }) else {
            return nil
        }
        return Binding(
            get: { viewModel.newCourse.modules[moduleIndex].lessons[lessonIndex] },
            set: { viewModel.newCourse.modules[moduleIndex].lessons[lessonIndex] = $0 }
        )
    }
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            
            if let lesson = lessonBinding {
                ScrollView {
                    VStack(spacing: 24) {
                        // Title Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Lesson Title")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            TextField("Enter lesson title", text: lesson.title)
                                .font(.title3)
                                .padding()
                                .background(Color(uiColor: .secondarySystemGroupedBackground))
                                .cornerRadius(12)
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(16)
                        .padding(.horizontal)
                        .padding(.top)
                        
                        // Content Type Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Content Type")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 16)], spacing: 16) {
                                ForEach(ContentType.allCases) { type in
                                    ContentTypeCard(
                                        type: type,
                                        isSelected: lesson.type.wrappedValue == type,
                                        action: { lesson.type.wrappedValue = type }
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Content Configuration (Placeholder based on type)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Content Details")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            VStack(spacing: 16) {
                                switch lesson.type.wrappedValue {
                                case .video:
                                    ContentPlaceholder(icon: "play.circle", text: "Upload Video or Enter URL")
                                case .pdf:
                                    ContentPlaceholder(icon: "doc.fill", text: "Upload PDF Document")
                                case .text:
                                    ContentPlaceholder(icon: "doc.text.fill", text: "Write or Paste Text Content")
                                case .presentation:
                                    ContentPlaceholder(icon: "rectangle.on.rectangle.fill", text: "Upload Slides")
                                case .quiz:
                                    ContentPlaceholder(icon: "checkmark.circle.fill", text: "Configure Quiz Questions")
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(32)
                            .background(Color(uiColor: .secondarySystemGroupedBackground))
                            .cornerRadius(12)
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 30)
                }
                .navigationTitle("Edit Lesson")
            } else {
                Text("Lesson not found")
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct ContentTypeCard: View {
    let type: ContentType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: type.icon)
                    .font(.system(size: 32))
                    .foregroundColor(isSelected ? .white : .blue)
                
                Text(type.rawValue)
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(
                isSelected ?
                LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing) :
                LinearGradient(colors: [Color(uiColor: .secondarySystemGroupedBackground)], startPoint: .top, endPoint: .bottom)
            )
            .cornerRadius(16)
            .shadow(color: isSelected ? .blue.opacity(0.3) : Color.black.opacity(0.05), radius: 8, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.clear : Color.blue.opacity(0.1), lineWidth: 1)
            )
        }
    }
}

struct ContentPlaceholder: View {
    let icon: String
    let text: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.largeTitle)
                .foregroundColor(.secondary)
            Text(text)
                .font(.headline)
                .foregroundColor(.secondary)
            
            Button("Choose File / Edit") {
                // Placeholder action
            }
            .buttonStyle(.bordered)
        }
    }
}
