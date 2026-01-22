//
//  GeminiService.swift
//  TLMS-project-main
//
//  Handles communication with Google Gemini API
//

import Foundation

enum GeminiError: Error, LocalizedError {
    case invalidURL
    case noAPIKey
    case networkError(Error)
    case invalidResponse
    case apiError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid API URL"
        case .noAPIKey: return "API Key is missing. Please add it to Secrets.swift"
        case .networkError(let error): return "Network error: \(error.localizedDescription)"
        case .invalidResponse: return "Invalid response from server"
        case .apiError(let message): return "Gemini API Error: \(message)"
        }
    }
}

class GeminiService {
    static let shared = GeminiService()
    
    private let baseURL = "https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent"
    
    private init() {}
    
    func sendMessage(_ text: String) async throws -> String {
        guard !Secrets.geminiApiKey.isEmpty, Secrets.geminiApiKey != "YOUR_GEMINI_API_KEY_HERE" else {
            throw GeminiError.noAPIKey
        }
        
        guard let url = URL(string: "\(baseURL)?key=\(Secrets.geminiApiKey)") else {
            throw GeminiError.invalidURL
        }
        
        // Request Body
        let body: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": text]
                    ]
                ]
            ]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                // Try to parse error message
                if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let errorObj = errorJson["error"] as? [String: Any],
                   let message = errorObj["message"] as? String {
                    throw GeminiError.apiError(message)
                }
                throw GeminiError.invalidResponse
            }
            
            // Parse Response
            struct GeminiResponse: Decodable {
                struct Candidate: Decodable {
                    struct Content: Decodable {
                        struct Part: Decodable {
                            let text: String
                        }
                        let parts: [Part]
                    }
                    let content: Content
                }
                let candidates: [Candidate]?
            }
            
            let decodedResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
            
            guard let candidate = decodedResponse.candidates?.first,
                  let part = candidate.content.parts.first else {
                return "I'm sorry, I couldn't generate a response."
            }
            
            return part.text
            
        } catch let error as GeminiError {
            throw error
        } catch {
            throw GeminiError.networkError(error)
        }
    }
    func listModels() async throws -> String {
        guard !Secrets.geminiApiKey.isEmpty else {
            throw GeminiError.noAPIKey
        }
        
        let urlString = "https://generativelanguage.googleapis.com/v1/models?key=\(Secrets.geminiApiKey)"
        guard let url = URL(string: urlString) else {
            throw GeminiError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw GeminiError.invalidResponse
        }
        
        struct ModelListResponse: Decodable {
            struct Model: Decodable {
                let name: String
                let displayName: String
                let supportedGenerationMethods: [String]
            }
            let models: [Model]
        }
        
        let decodedResponse = try JSONDecoder().decode(ModelListResponse.self, from: data)
        
        let chatModels = decodedResponse.models.filter { $0.supportedGenerationMethods.contains("generateContent") }
        
        let modelList = chatModels.map { "- \($0.displayName) (`\($0.name)`)" }.joined(separator: "\n")
        
        return "Available Models:\n\n\(modelList)"
    }
}
