//
//  PaymentWebView.swift
//  TLMS-project-main
//
//  Web view for Razorpay checkout
//

import SwiftUI
import WebKit

struct PaymentWebView: View {
    let paymentURL: URL
    let onSuccess: (String) -> Void // Payment ID
    let onFailure: () -> Void
    @Environment(\.dismiss) var dismiss
    
    @State private var isLoading = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                WebView(
                    url: paymentURL,
                    isLoading: $isLoading,
                    onSuccess: { paymentId in
                        onSuccess(paymentId)
                        dismiss()
                    },
                    onFailure: {
                        onFailure()
                        dismiss()
                    }
                )
                
                if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading payment...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(uiColor: .systemBackground))
                }
            }
            .navigationTitle("Payment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onFailure()
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - WebView Wrapper

struct WebView: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool
    let onSuccess: (String) -> Void
    let onFailure: () -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url {
                let urlString = url.absoluteString
                
                // Check for custom payment scheme
                if urlString.starts(with: "payment://success") {
                    // Extract payment ID from URL
                    if let paymentId = extractPaymentId(from: urlString) {
                        parent.onSuccess(paymentId)
                    } else {
                        // If no payment ID, still mark as success (for testing)
                        parent.onSuccess("test_payment_\(UUID().uuidString.prefix(10))")
                    }
                    decisionHandler(.cancel)
                    return
                }
                
                // Check for cancel
                if urlString.starts(with: "payment://cancel") {
                    parent.onFailure()
                    decisionHandler(.cancel)
                    return
                }
            }
            
            decisionHandler(.allow)
        }
        
        private func extractPaymentId(from urlString: String) -> String? {
            // Extract payment ID from URL parameters
            guard let components = URLComponents(string: urlString),
                  let queryItems = components.queryItems else {
                return nil
            }
            
            return queryItems.first(where: { $0.name == "payment_id" })?.value
        }
    }
}
