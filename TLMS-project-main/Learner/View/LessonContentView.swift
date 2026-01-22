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
            
            // MARK: - Sidebar Overlay
            if showSidebar {
                sidebarOverlay
            }
        }
        .background(AppTheme.groupedBackground)
        .navigationTitle("Lesson")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    selectedLesson = nil
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "xmark.circle.fill")
                        Text("Close")
                    }
                    .foregroundColor(AppTheme.primaryBlue)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    withAnimation { showSidebar.toggle() }
                } label: {
                    Image(systemName: "list.bullet.sidebar")
                        .font(.system(size: 16, weight: .semibold))
                }
            }
        }
        // Load initial state
        .task {
            await loadAllCompletions()
        }
        // Watch for lesson changes (if logic requires re-check, though set is global for course)
        .onChange(of: selectedLesson?.id) { _ in
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
            videoContentView
            
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
    
    private var videoContentView: some View {
        Group {
            if let urlStr = lesson.fileURL,
               let url = URL(string: urlStr) {

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
                    VStack(spacing: 8) {

                        // Header + actions
                        HStack {
                            Text("Transcript")
                                .font(.headline)

                            Spacer()

                            // Download (only if transcript exists)
                            if let transcript = lesson.transcript,
                               !transcript.isEmpty {

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
                            }

                            Button(showTranscript ? "Hide" : "Show") {
                                showTranscript.toggle()
                            }
                            .foregroundColor(AppTheme.primaryBlue)
                        }

                        // Transcript content
                        if showTranscript {
                            if let transcript = lesson.transcript,
                               !transcript.isEmpty {

                                ScrollView {
                                    Text(transcript)
                                        .lineSpacing(6)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .frame(maxHeight: 250)

                            } else {
                                Text("No transcript available.")
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.secondaryText)
                            }
                        }
                    }
                    .padding()
                    .background(AppTheme.secondaryGroupedBackground)
                    .cornerRadius(AppTheme.cornerRadius)
                }

            } else {
                EmptyContentView(message: "Invalid video URL.")
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
            }
            .padding(.top, 8)
        } else {
            Button(action: moveToNextLesson) {
                HStack {
                    Text("Continue to Next Lesson")
                        .font(.headline)
                    Image(systemName: "arrow.right")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppTheme.primaryText)
                .foregroundColor(AppTheme.groupedBackground)
                .cornerRadius(AppTheme.cornerRadius)
            }
            .padding(.top, 8)
        }
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
                    showCompletionAlert = true
                }

                // Update course progress in DB
                await courseService.updateCourseProgress(userId: userId, course: course)

                // 🔔 STEP C: notify dashboard
                NotificationCenter.default.post(
                    name: .courseProgressUpdated,
                    object: nil
                )
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

// Keep helper views like EmptyContentView if they are not in other files
// Assuming EmptyContentView, PDFViewRepresentable, WebViewRepresentable are used here 
// but checking the previous file content, they were defined in the same file.
// I should preserve them.

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
}
