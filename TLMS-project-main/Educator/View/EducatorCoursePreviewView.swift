import SwiftUI
import PDFKit
import AVKit
import WebKit

/// Educator view to preview published courses and their content
struct EducatorCoursePreviewView: View {
    let courseId: UUID
    var draftCourse: Course? = nil // Optional draft course for immediate preview
    @StateObject private var courseService = CourseService()
    @State private var course: Course?
    @State private var isLoading = true
    @State private var expandedModules: Set<UUID> = []
    @State private var selectedLesson: Lesson?
    @State private var showLessonContent = false
    @State private var showEditCourse = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            AppTheme.groupedBackground
                .ignoresSafeArea()
            
            if isLoading {
                ProgressView("Loading course...")
                    .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.primaryAccent))
            } else if let course = course {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Course Header
                        courseHeaderView(course: course)
                        
                        // Course Content
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                Text("Course Content")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(AppTheme.primaryText)
                                
                                Spacer()
                                
                                Text("\(course.modules.count) Modules")
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.secondaryText)
                            }
                            .padding(.horizontal)
                            .padding(.top, 8)
                            
                            VStack(spacing: 16) {
                                ForEach(Array(course.modules.enumerated()), id: \.element.id) { index, module in
                                    ModulePreviewCard(
                                        module: module,
                                        moduleNumber: index + 1,
                                        isExpanded: expandedModules.contains(module.id),
                                        isEnrolled: true,
                                        onToggle: {
                                            if expandedModules.contains(module.id) {
                                                expandedModules.remove(module.id)
                                            } else {
                                                expandedModules.insert(module.id)
                                            }
                                        },
                                        onLessonTap: { lesson in
                                            selectedLesson = lesson
                                            showLessonContent = true
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.bottom, 60)
                    }
                }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(AppTheme.secondaryText)
                    Text("Course not found")
                        .font(.headline)
                        .foregroundColor(AppTheme.primaryText)
                }
            }
        }
        .navigationTitle("Course Preview")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if let course = course, course.status == .draft {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showEditCourse = true
                    }) {
                        Text("Edit")
                            .font(.body)
                            .foregroundColor(AppTheme.primaryBlue)
                    }
                }
            }
        }
        .task {
            await loadCourse()
        }
        .fullScreenCover(isPresented: $showEditCourse) {
            if let course = course {
                NavigationStack {
                    CreateCourseView(viewModel: CourseCreationViewModel(educatorID: course.educatorID, existingCourse: course))
                }
            }
        }
        .sheet(isPresented: $showLessonContent) {
            if let lesson = selectedLesson, let course = course {
                NavigationView {
                    EducatorLessonContentView(lesson: lesson, course: course)
                }
            }
        }
    }
    
    private func courseHeaderView(course: Course) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // MARK: - Premium Image Header
            ZStack(alignment: .bottomLeading) {
                // Course Image
                let imageName = CourseImageHelper.getCourseImage(courseCoverUrl: course.courseCoverUrl, category: course.category)
                
                if let uiImage = UIImage(named: imageName) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(minHeight: 200) // Reduced from 220
                        .clipped()
                } else {
                    // Fallback gradient
                    LinearGradient(
                        colors: [course.categoryColor.opacity(0.8), course.categoryColor.opacity(0.4)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(minHeight: 200) // Reduced from 220
                    .overlay(
                        Image(systemName: course.categoryIcon)
                            .font(.system(size: 80, weight: .bold))
                            .foregroundColor(.white.opacity(0.2))
                    )
                }
                
                // Dark Overlay for readability
                LinearGradient(
                    colors: [.clear, .black.opacity(0.8)],
                    startPoint: .center,
                    endPoint: .bottom
                )
                .frame(minHeight: 200) // Reduced from 220
                
                // Title and Category Overlay
                VStack(alignment: .leading, spacing: 8) {
                    Text(course.category.uppercased())
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(course.categoryColor.opacity(0.8))
                        .cornerRadius(4)
                    
                    Text(course.title)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.6), radius: 4, x: 0, y: 2)
                        .minimumScaleFactor(0.6)
                        .lineLimit(2)
                        .padding(.bottom, 20) // Add padding to avoid overlapping the card
                }
                .padding(24)
            }
            .cornerRadius(20, corners: [.bottomLeft, .bottomRight])
            .ignoresSafeArea(edges: .top)
            
            // MARK: - Course Details Card
            VStack(alignment: .leading, spacing: 20) {
                // Metrics Row
                HStack(spacing: 12) {
                    // Rating
                    if let rating = course.ratingAvg, rating > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.orange)
                            Text(String(format: "%.1f", rating))
                                .fontWeight(.bold)
                            Text("(\(course.ratingCount))")
                                .foregroundColor(AppTheme.secondaryText)
                        }
                        .fixedSize(horizontal: true, vertical: false)
                    } else {
                        Text("No ratings yet")
                            .font(.subheadline.italic())
                            .foregroundColor(AppTheme.secondaryText)
                            .fixedSize(horizontal: true, vertical: false)
                    }
                    
                    Spacer()
                    
                    // Price/Level
                    HStack(spacing: 8) {
                        if let price = course.price, price > 0 {
                            Text(price.formatted(.currency(code: "INR")))
                                .font(.headline)
                                .foregroundColor(AppTheme.primaryBlue)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(AppTheme.primaryBlue.opacity(0.1))
                                .cornerRadius(8)
                                .fixedSize(horizontal: true, vertical: false)
                        } else {
                            Text("Free")
                                .font(.headline)
                                .foregroundColor(AppTheme.successGreen)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(AppTheme.successGreen.opacity(0.1))
                                .cornerRadius(8)
                                .fixedSize(horizontal: true, vertical: false)
                        }
                        
                        Text(course.level.rawValue)
                            .font(.subheadline.weight(.medium))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(AppTheme.secondaryText.opacity(0.1))
                            .cornerRadius(8)
                            .fixedSize(horizontal: true, vertical: false)
                    }
                }
                
                // Description
                VStack(alignment: .leading, spacing: 8) {
                    Text("About this Course")
                        .font(.headline)
                        .foregroundColor(AppTheme.primaryText)
                    
                    Text(course.description)
                        .font(.body)
                        .foregroundColor(AppTheme.secondaryText)
                        .lineSpacing(4)
                }
                
                // Stats Row
                HStack(spacing: 12) {
                    HStack(spacing: 6) {
                        Image(systemName: "person.2.fill")
                        Text("\(course.enrollmentCount) Enrolled")
                    }
                    .fixedSize(horizontal: true, vertical: false)
                    
                    HStack(spacing: 6) {
                        Image(systemName: "book.fill")
                        Text("\(course.modules.count) Modules")
                    }
                    .fixedSize(horizontal: true, vertical: false)
                    
                    Spacer()
                    
                    // Status Badge
                    HStack(spacing: 4) {
                        Image(systemName: course.status.icon)
                        Text(course.status.displayName)
                    }
                    .font(.caption.bold())
                    .foregroundColor(course.status.color)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(course.status.color.opacity(0.1))
                    .cornerRadius(6)
                    .fixedSize(horizontal: true, vertical: false)
                }
                .font(.subheadline)
                .foregroundColor(AppTheme.secondaryText)
            }
            .padding(20)
            .background(AppTheme.secondaryGroupedBackground)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
            .padding(.horizontal)
            .padding(.top, -30) // Overlap with image
        }
    }
    
    private func loadCourse() async {
        isLoading = true
        // Use draft course if provided, otherwise fetch by ID
        if let draftCourse = draftCourse {
            course = draftCourse
        } else {
            course = await courseService.fetchCourse(by: courseId)
        }
        isLoading = false
    }
}

/// Educator-specific lesson content viewer (read-only, no completion tracking)
struct EducatorLessonContentView: View {
    let lesson: Lesson
    let course: Course
    @Environment(\.dismiss) var dismiss
    @State private var showTranscript = true
    @State private var transcriptFileURL: URL?
    
    var body: some View {
        ZStack {
            AppTheme.groupedBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    headerView
                    
                    // Content
                    contentView
                }
                .padding()
            }
        }
        .navigationTitle(lesson.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: lesson.type.icon)
                    .font(.title3)
                    .foregroundColor(AppTheme.primaryAccent)
                
                Text(lesson.type.rawValue)
                    .font(.caption)
                    .foregroundColor(AppTheme.secondaryText)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AppTheme.primaryAccent.opacity(0.1))
                    .cornerRadius(8)
                
                Spacer()
            }
            
            Text(lesson.title)
                .font(.title2.bold())
                .foregroundColor(AppTheme.primaryText)
            
            if let description = lesson.contentDescription {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(AppTheme.secondaryText)
            }
        }
        .padding()
        .background(AppTheme.secondaryGroupedBackground)
        .cornerRadius(AppTheme.cornerRadius)
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch lesson.type {
        case .text:
            if let text = lesson.textContent, !text.isEmpty {
                Text(text)
                    .font(.body)
                    .foregroundColor(AppTheme.primaryText)
                    .lineSpacing(6)
                    .padding()
                    .background(AppTheme.secondaryGroupedBackground)
                    .cornerRadius(AppTheme.cornerRadius)
            } else {
                EmptyContentView(message: "No text content available.")
            }
            
        case .video:
            videoContentView
            
        case .pdf:
            if let urlStr = lesson.fileURL, let url = URL(string: urlStr) {
                DocumentViewer(url: url, fileName: lesson.fileName ?? "Document.pdf", documentType: .pdf)
            } else {
                EmptyContentView(message: "PDF not available.")
            }
            
        case .presentation:
            if let urlStr = lesson.fileURL, let url = URL(string: urlStr) {
                DocumentViewer(url: url, fileName: lesson.fileName ?? "Presentation", documentType: .powerpoint)
            } else {
                EmptyContentView(message: "Presentation not available.")
            }
            
        case .quiz:
            quizPreviewView
        }
    }
    
    private var videoContentView: some View {
        Group {
            if let urlStr = lesson.fileURL, let url = URL(string: urlStr) {
                VStack(spacing: 16) {
                    // Video Player
                    VideoPlayer(player: AVPlayer(url: url))
                        .frame(height: 250)
                        .cornerRadius(AppTheme.cornerRadius)
                    
                    // About section
                    if let desc = lesson.contentDescription {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("About this video")
                                .font(.headline)
                            
                            Text(desc)
                                .font(.body)
                                .foregroundColor(AppTheme.secondaryText)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppTheme.secondaryGroupedBackground)
                        .cornerRadius(AppTheme.cornerRadius)
                    }
                    
                    // Transcript Section
                    if let transcript = lesson.transcript, !transcript.isEmpty {
                        VStack(spacing: 8) {
                            HStack {
                                Text("Transcript")
                                    .font(.headline)
                                
                                Spacer()
                                
                                Button {
                                    transcriptFileURL = createTranscriptFile(from: transcript)
                                } label: {
                                    Image(systemName: "arrow.down.doc")
                                }
                                
                                if let fileURL = transcriptFileURL {
                                    ShareLink(item: fileURL) {
                                        Image(systemName: "square.and.arrow.up")
                                    }
                                }
                                
                                Button(showTranscript ? "Hide" : "Show") {
                                    showTranscript.toggle()
                                }
                                .foregroundColor(AppTheme.primaryBlue)
                            }
                            
                            if showTranscript {
                                ScrollView {
                                    Text(transcript)
                                        .lineSpacing(6)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .frame(maxHeight: 250)
                            }
                        }
                        .padding()
                        .background(AppTheme.secondaryGroupedBackground)
                        .cornerRadius(AppTheme.cornerRadius)
                    }
                }
            } else {
                EmptyContentView(message: "Invalid video URL.")
            }
        }
    }
    
    private var quizPreviewView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "checkmark.circle.badge.questionmark.fill")
                    .font(.title)
                    .foregroundColor(AppTheme.primaryBlue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Quiz")
                        .font(.headline)
                        .foregroundColor(AppTheme.primaryText)
                    
                    if let timeLimit = lesson.quizTimeLimit {
                        Text("Time limit: \(timeLimit) minutes")
                            .font(.caption)
                            .foregroundColor(AppTheme.secondaryText)
                    }
                    
                    if let passingScore = lesson.quizPassingScore {
                        Text("Passing score: \(passingScore)%")
                            .font(.caption)
                            .foregroundColor(AppTheme.secondaryText)
                    }
                }
                
                Spacer()
            }
            .padding()
            .background(AppTheme.secondaryGroupedBackground)
            .cornerRadius(AppTheme.cornerRadius)
            
            // Quiz questions preview
            if let questions = lesson.quizQuestions, !questions.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Questions (\(questions.count))")
                        .font(.headline)
                        .foregroundColor(AppTheme.primaryText)
                    
                    ForEach(Array(questions.enumerated()), id: \.element.id) { index, question in
                        EducatorQuestionPreviewCard(question: question, questionNumber: index + 1)
                    }
                }
            } else {
                EmptyContentView(message: "No questions added to this quiz.")
            }
        }
    }
    
    private func createTranscriptFile(from text: String) -> URL? {
        let safeTitle = lesson.title
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "/", with: "_")
        
        let fileName = "\(safeTitle)_Transcript.txt"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try text.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            print("❌ Failed to create transcript file:", error)
            return nil
        }
    }
}

// MARK: - Educator Question Preview Card (renamed to avoid conflict)

struct EducatorQuestionPreviewCard: View {
    let question: Question
    let questionNumber: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Question header
            HStack {
                Text("Question \(questionNumber)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(AppTheme.primaryBlue)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: question.type.icon)
                        .font(.caption2)
                    Text(question.type.displayName)
                        .font(.caption2)
                }
                .foregroundColor(AppTheme.secondaryText)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(AppTheme.secondaryText.opacity(0.1))
                .cornerRadius(6)
                
                Text("\(question.points) pts")
                    .font(.caption.weight(.medium))
                    .foregroundColor(AppTheme.successGreen)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.successGreen.opacity(0.1))
                    .cornerRadius(6)
            }
            
            // Question text
            Text(question.text)
                .font(.body)
                .foregroundColor(AppTheme.primaryText)
            
            // Options or character limit
            if question.type == .descriptive {
                HStack {
                    Image(systemName: "text.alignleft")
                        .font(.caption)
                    Text("Text answer (max \(question.characterLimit) characters)")
                        .font(.caption)
                }
                .foregroundColor(AppTheme.secondaryText)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(AppTheme.secondaryText.opacity(0.1))
                .cornerRadius(6)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                        HStack(spacing: 12) {
                            Image(systemName: question.correctAnswerIndices.contains(index) ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(question.correctAnswerIndices.contains(index) ? AppTheme.successGreen : AppTheme.secondaryText)
                            
                            Text(option)
                                .font(.subheadline)
                                .foregroundColor(AppTheme.primaryText)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(question.correctAnswerIndices.contains(index) ? AppTheme.successGreen.opacity(0.1) : AppTheme.secondaryGroupedBackground)
                        .cornerRadius(8)
                    }
                }
            }
            
            // Explanation if available
            if let explanation = question.explanation, !explanation.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Explanation:")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(AppTheme.primaryBlue)
                    
                    Text(explanation)
                        .font(.caption)
                        .foregroundColor(AppTheme.secondaryText)
                }
                .padding(12)
                .background(AppTheme.primaryBlue.opacity(0.05))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(AppTheme.secondaryGroupedBackground)
        .cornerRadius(AppTheme.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}
