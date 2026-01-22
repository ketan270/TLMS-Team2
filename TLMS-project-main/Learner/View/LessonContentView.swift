import SwiftUI
import PDFKit
import AVKit
import WebKit

struct LessonContentView: View {
    let lesson: Lesson
    let course: Course
    let userId: UUID
    @Binding var selectedLesson: Lesson?
    var isPreviewMode: Bool = false  // Add this to hide completion button for admin preview
    
    // MARK: - State
    /// Single source of truth for completion status
    @State private var completedLessonIds: Set<UUID> = []
    @State private var showCompletionAlert = false
    @State private var showSidebar = false
    @State private var showTranscript = true
    @State private var isLoading = false
    @State private var transcriptFileURL: URL?
    @State private var isQuizActive = false
    @State private var showCompletionView = false
    
    @StateObject private var courseService = CourseService()
    
    // Derived state for the CURRENT lesson
    private var isCurrentLessonCompleted: Bool {
        completedLessonIds.contains(lesson.id)
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            // For PDF lessons, show full screen without scroll
            if lesson.type == .pdf {
                pdfFullScreenView
            } else {
                // For other content types, use normal scroll view
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // MARK: - Header
                        headerView
                        
                        // MARK: - Content
                        contentView
                        
                        // MARK: - Footer Actions (hide for preview mode)
                        if !isPreviewMode {
                            footerActionView
                        }
                    }
                    .padding()
                }
            }
            
            if showSidebar {
                sidebarOverlay
            }
        }
        .fullScreenCover(isPresented: $showCompletionView) {
            CourseCompletionView(
                course: course,
                userId: userId,
                onDismiss: { showCompletionView = false },
                onViewCertificate: {
                    // Navigate to certificate view or handle deep link
                    showCompletionView = false
                }
            )
        }
        .background(AppTheme.groupedBackground)
        .navigationTitle("Lesson")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    withAnimation { showSidebar.toggle() }
                } label: {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 18))
                }
            }
        }
        // Load initial state
        .task {
            await loadAllCompletions()
        }
        // Watch for lesson changes (if logic requires re-check)
        .onChange(of: selectedLesson?.id) { oldValue, newValue in
            // Maybe scroll to top?
        }
        .alert("Lesson Complete!", isPresented: $showCompletionAlert) {
            Button("Continue", role: .cancel) {
                moveToNextLesson()
            }
        } message: {
            Text("Great job! You've completed this lesson.")
        }
    }
    
    // MARK: - Views
    
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
                
                if isCurrentLessonCompleted {
                    Label("Completed", systemImage: "checkmark.circle.fill")
                        .font(.caption.bold())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(AppTheme.successGreen.opacity(0.1))
                        .foregroundColor(AppTheme.successGreen)
                        .cornerRadius(8)
                }
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
            if let urlStr = lesson.fileURL, let url = URL(string: urlStr) {
                VStack(spacing: 24) {
                    // Modern Video Player with Transcript
                    VideoPlayerWithTranscript(
                        videoURL: url,
                        transcript: lesson.transcript,
                        onVideoCompleted: {
                            if !isCurrentLessonCompleted {
                                autoCompleteLesson()
                            }
                        }
                    )
                    .background(AppTheme.secondaryGroupedBackground)
                    .cornerRadius(AppTheme.cornerRadius)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    
                    // About section Card
                    if let desc = lesson.contentDescription {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(AppTheme.primaryBlue)
                                Text("About this video")
                                    .font(.headline)
                            }
                            
                            Text(desc)
                                .font(.body)
                                .foregroundColor(AppTheme.secondaryText)
                                .lineSpacing(4)
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                .fill(AppTheme.secondaryGroupedBackground)
                                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                        )
                    }
                }
                .padding(.vertical, 8)
            } else {
                EmptyContentView(message: "Video content is temporarily unavailable.")
            }
            
        case .pdf:
            if let urlStr = lesson.fileURL, let url = URL(string: urlStr) {
                DocumentViewer(url: url, fileName: lesson.fileName ?? "Document.pdf", documentType: .pdf)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.bottom)
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
            VStack(spacing: 24) {
                Image(systemName: "checkmark.circle.badge.questionmark.fill")
                    .font(.system(size: 64))
                    .foregroundColor(AppTheme.primaryBlue)
                    .padding(.top, 40)
                
                Text("Ready to test your knowledge?")
                    .font(.title3.bold())
                    .foregroundColor(AppTheme.primaryText)
                
                if let timeLimit = lesson.quizTimeLimit {
                    Label("\(timeLimit) minutes", systemImage: "clock")
                        .font(.headline)
                        .foregroundColor(AppTheme.secondaryText)
                }
                
                Button(action: {
                    isQuizActive = true
                }) {
                    Text("Start Quiz")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.primaryBlue)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
                
                Text("Once started, you cannot leave until the quiz is submitted.")
                    .font(.caption)
                    .foregroundColor(AppTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(AppTheme.secondaryGroupedBackground)
            .cornerRadius(AppTheme.cornerRadius)
            .navigationDestination(isPresented: $isQuizActive) {
                LearnerQuizView(lesson: lesson, isPresented: $isQuizActive)
            }
        }
    }

    // MARK: - Transcript Download Helper
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
    
    @ViewBuilder
    private var footerActionView: some View {
        VStack(spacing: 16) {
            // Only show manual complete button for non-video lessons
            if lesson.type != .video {
                if !isCurrentLessonCompleted {
                    Button(action: markAsComplete) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Mark as Complete")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.primaryBlue)
                        .foregroundColor(.white)
                        .cornerRadius(AppTheme.cornerRadius)
                        .shadow(color: AppTheme.primaryBlue.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                }
            }
            
            // Show "Continue" or "Certificate" button
            if isCurrentLessonCompleted {
                if let next = determineNextLesson() {
                    Button(action: { selectedLesson = next }) {
                        HStack {
                            Text("Continue to \(next.title)")
                                .font(.headline)
                            Image(systemName: "arrow.right")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.primaryText)
                        .foregroundColor(AppTheme.groupedBackground)
                        .cornerRadius(AppTheme.cornerRadius)
                        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                    }
                } else {
                    // No next lesson -> Course completed!
                    Button(action: { showCompletionView = true }) {
                        HStack {
                            Image(systemName: "graduationcap.fill")
                            Text("Claim Your Certificate")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.successGreen)
                        .foregroundColor(.white)
                        .cornerRadius(AppTheme.cornerRadius)
                        .shadow(color: AppTheme.successGreen.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                }
            }
        }
        .padding(.vertical, 16)
    }
    
    private var sidebarOverlay: some View {
        ZStack(alignment: .leading) {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { withAnimation { showSidebar = false } }
            
            SideMenuView(
                course: course,
                completedLessonIds: completedLessonIds,
                selectedLesson: $selectedLesson,
                isPresented: $showSidebar
            )
            .frame(width: 300)
            .transition(.move(edge: .leading))
        }
        .zIndex(2)
    }
    
    // MARK: - Logic
    
    private func loadAllCompletions() async {
        let ids = await courseService.fetchCompletedLessonIds(userId: userId, courseId: course.id)
        await MainActor.run {
            self.completedLessonIds = ids
        }
    }
    
    // Auto-complete for videos (no alert, just moves to next)
    private func autoCompleteLesson() {
        Task {
            let success = await courseService.markLessonComplete(
                userId: userId,
                courseId: course.id,
                lessonId: lesson.id
            )

            if success {
                await MainActor.run {
                    completedLessonIds.insert(lesson.id)
                }

                // Update course progress in DB
                await courseService.updateCourseProgress(userId: userId, course: course)

                // Notify dashboard
                NotificationCenter.default.post(
                    name: .courseProgressUpdated,
                    object: nil
                )
                
                // Auto-move to next lesson after a brief delay
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                await MainActor.run {
                    if let next = determineNextLesson() {
                        selectedLesson = next
                    } else {
                        // All lessons completed!
                        showCompletionView = true
                    }
                }
            }
        }
    }
    
    private func markAsComplete() {
        Task {
            isLoading = true
            let success = await courseService.markLessonComplete(
                userId: userId,
                courseId: course.id,
                lessonId: lesson.id
            )

            if success {
                await MainActor.run {
                    completedLessonIds.insert(lesson.id)
                }

                // Update course progress in DB
                await courseService.updateCourseProgress(userId: userId, course: course)

                // Notify dashboard
                NotificationCenter.default.post(
                    name: .courseProgressUpdated,
                    object: nil
                )
                
                // Move to next lesson (no alert, stay in flow)
                await MainActor.run {
                    if let next = determineNextLesson() {
                        selectedLesson = next
                    } else {
                        // All lessons completed!
                        showCompletionView = true
                    }
                }
            }
            isLoading = false
        }
    }
    
    private func moveToNextLesson() {
        guard let next = determineNextLesson() else { return }
        selectedLesson = next
    }
    
    private func determineNextLesson() -> Lesson? {
        for (mIndex, module) in course.modules.enumerated() {
            if let lIndex = module.lessons.firstIndex(where: { $0.id == lesson.id }) {
                // Check next in module
                if lIndex + 1 < module.lessons.count {
                    return module.lessons[lIndex + 1]
                }
                // Check next module
                if mIndex + 1 < course.modules.count {
                    return course.modules[mIndex + 1].lessons.first
                }
            }
        }
        return nil
    }
}

// MARK: - Empty Content View

struct EmptyContentView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundColor(AppTheme.secondaryText.opacity(0.6))
            Text(message)
                .font(.subheadline)
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(AppTheme.secondaryGroupedBackground)
        .cornerRadius(AppTheme.cornerRadius)
    }
}

struct PDFViewRepresentable: UIViewRepresentable {
    let url: URL
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        if let document = PDFDocument(url: url) {
            pdfView.document = document
        }
        return pdfView
    }
    func updateUIView(_ uiView: PDFView, context: Context) {}
}

struct WebViewRepresentable: UIViewRepresentable {
    let url: URL
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

// MARK: - PDF Full Screen View Extension

extension LessonContentView {
    @ViewBuilder
    var pdfFullScreenView: some View {
        if let urlStr = lesson.fileURL, let url = URL(string: urlStr) {
            DocumentViewer(url: url, fileName: lesson.fileName ?? "Document.pdf", documentType: .pdf)
                .ignoresSafeArea(.all, edges: .bottom)
        } else {
            VStack {
                Spacer()
                EmptyContentView(message: "PDF not available.")
                Spacer()
            }
        }
    }
}


extension Notification.Name {
    static let courseProgressUpdated = Notification.Name("courseProgressUpdated")
    static let courseEnrolled = Notification.Name("courseEnrolled")
}
