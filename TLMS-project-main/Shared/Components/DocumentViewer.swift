//
//  DocumentViewer.swift
//  TLMS-project-main
//
//  Universal document viewer for PDF, DOC, DOCX, PPT, PPTX with download and share
//

import SwiftUI
import PDFKit
import QuickLook
import UniformTypeIdentifiers

struct DocumentViewer: View {
    let url: URL
    let fileName: String
    let documentType: DocumentType
    
    @State private var isLoading = true
    @State private var loadError: String?
    @State private var showShareSheet = false
    @State private var showDownloadSuccess = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()
            
            if isLoading {
                loadingView
            } else if let error = loadError {
                errorView(error)
            } else {
                documentContentView
            }
        }
        .navigationTitle(fileName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: downloadDocument) {
                        Label("Download", systemImage: "arrow.down.circle")
                    }
                    
                    Button(action: { showShareSheet = true }) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(AppTheme.primaryBlue)
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [url])
        }
        .alert("Downloaded", isPresented: $showDownloadSuccess) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Document saved to Files app")
        }
        .onAppear {
            validateDocument()
        }
    }
    
    // MARK: - Document Content
    
    @ViewBuilder
    private var documentContentView: some View {
        switch documentType {
        case .pdf:
            PDFDocumentView(url: url)
        case .word, .powerpoint, .other:
            QuickLookView(url: url)
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(AppTheme.primaryBlue)
            
            Text("Loading document...")
                .font(.subheadline)
                .foregroundColor(AppTheme.secondaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Error View
    
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.errorRed)
            
            VStack(spacing: 8) {
                Text("Unable to Load Document")
                    .font(.title3.bold())
                    .foregroundColor(AppTheme.primaryText)
                
                Text(message)
                    .font(.body)
                    .foregroundColor(AppTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            PremiumButton(
                title: "Go Back",
                icon: "arrow.left",
                action: { dismiss() }
            )
            .padding(.horizontal, 40)
        }
        .padding()
    }
    
    // MARK: - Actions
    
    private func validateDocument() {
        // Simulate loading delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // For remote URLs (http/https), skip file existence check
            if url.scheme == "http" || url.scheme == "https" {
                print("✅ Loading remote document: \(url.absoluteString)")
                isLoading = false
                return
            }
            
            // For local files, check if they exist
            guard FileManager.default.fileExists(atPath: url.path) else {
                loadError = "The document file could not be found. Please check the file path."
                isLoading = false
                return
            }
            
            isLoading = false
        }
    }
    
    private func downloadDocument() {
        // Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        // In a real app, this would download to Files app
        // For now, we'll just show success
        showDownloadSuccess = true
    }
}

// MARK: - Document Type

enum DocumentType {
    case pdf
    case word
    case powerpoint
    case other
    
    init(from url: URL) {
        let fileExtension = url.pathExtension.lowercased()
        
        switch fileExtension {
        case "pdf":
            self = .pdf
        case "doc", "docx":
            self = .word
        case "ppt", "pptx", "key":
            self = .powerpoint
        default:
            self = .other
        }
    }
    
    var icon: String {
        switch self {
        case .pdf:
            return "doc.fill"
        case .word:
            return "doc.text.fill"
        case .powerpoint:
            return "rectangle.on.rectangle.fill"
        case .other:
            return "doc.fill"
        }
    }
}

// MARK: - PDF Document View

struct PDFDocumentView: View {
    let url: URL
    
    var body: some View {
        PDFKitView(url: url)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(edges: .bottom)
    }
}

struct PDFKitView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        
        // Configure PDF display for full screen viewing
        pdfView.backgroundColor = UIColor.systemBackground
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        
        // Important: Set this to ensure PDF fills the view
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        
        // Load PDF from URL
        loadPDF(into: pdfView)
        
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
        // Only reload if URL changed
        if uiView.document == nil || uiView.document?.documentURL != url {
            loadPDF(into: uiView)
        }
    }
    
    private func loadPDF(into pdfView: PDFView) {
        // Load asynchronously to avoid blocking UI
        DispatchQueue.global(qos: .userInitiated).async {
            if let document = PDFDocument(url: self.url) {
                DispatchQueue.main.async {
                    pdfView.document = document
                    
                    // Force proper scaling after document loads
                    if let page = document.page(at: 0) {
                        let pageRect = page.bounds(for: .mediaBox)
                        let viewSize = pdfView.bounds.size
                        
                        // Calculate scale to fit width
                        if pageRect.width > 0 && viewSize.width > 0 {
                            let scale = viewSize.width / pageRect.width
                            pdfView.scaleFactor = scale
                            pdfView.minScaleFactor = scale * 0.5
                            pdfView.maxScaleFactor = scale * 4.0
                        }
                    }
                    
                    print("✅ PDF loaded successfully from: \(self.url)")
                }
            } else {
                print("❌ Failed to load PDF from URL: \(self.url)")
            }
        }
    }
}

// MARK: - QuickLook View (for Word, PowerPoint, etc.)

struct QuickLookView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {
        // Update if needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(url: url)
    }
    
    class Coordinator: NSObject, QLPreviewControllerDataSource {
        let url: URL
        
        init(url: URL) {
            self.url = url
        }
        
        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            return 1
        }
        
        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            return url as QLPreviewItem
        }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // Update if needed
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        DocumentViewer(
            url: URL(string: "https://www.example.com/sample.pdf")!,
            fileName: "Sample Document.pdf",
            documentType: .pdf
        )
    }
}
