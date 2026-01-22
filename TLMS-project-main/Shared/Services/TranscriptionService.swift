import Foundation
import Speech
import AVFoundation
import Combine

class TranscriptionService: ObservableObject {
    @Published var isTranscribing = false
    @Published var transcriptionProgress: Double = 0.0
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    
    /// Automates transcript generation for a given video URL
    func transcribeVideo(url: URL) async throws -> String {
        guard let speechRecognizer = speechRecognizer else {
            throw TranscriptionError.recognizerUnavailable
        }
        
        if !speechRecognizer.isAvailable {
            throw TranscriptionError.recognizerUnavailable
        }

        // 1. Request Authorization
        let authorized = await requestAuthorization()
        guard authorized else {
            throw TranscriptionError.notAuthorized
        }
        
        await MainActor.run { isTranscribing = true }
        defer { 
            DispatchQueue.main.async {
                self.isTranscribing = false 
            }
        }
        
        // 2. Extract Audio from Video (SFSpeechURLRecognitionRequest needs audio)
        let request = SFSpeechURLRecognitionRequest(url: url)
        request.shouldReportPartialResults = false
        
        return try await withCheckedThrowingContinuation { continuation in
            var isFinished = false
            
            let task = speechRecognizer.recognitionTask(with: request) { result, error in
                if isFinished { return }
                
                if let error = error {
                    isFinished = true
                    continuation.resume(throwing: error)
                    return
                }
                
                if let result = result, result.isFinal {
                    isFinished = true
                    let formattedTranscript = self.formatTranscription(result)
                    continuation.resume(returning: formattedTranscript)
                }
            }
            
            // Handle timeout or cancellation if needed, but for now this is safer
        }
    }
    
    private func requestAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
    
    /// Formats the transcribed segments with [MM:SS] timestamps for our player
    private func formatTranscription(_ result: SFSpeechRecognitionResult) -> String {
        var transcript = ""
        var lastTimestamp: Double = -5.0 // Start a bit before
        
        for segment in result.bestTranscription.segments {
            // Only add a timestamp every ~5 seconds or at the start of a clear sentence
            if segment.timestamp >= lastTimestamp + 5.0 {
                let minutes = Int(segment.timestamp) / 60
                let seconds = Int(segment.timestamp) % 60
                let timestampStr = String(format: "[%02d:%02d]", minutes, seconds)
                
                if !transcript.isEmpty { transcript += "\n" }
                transcript += "\(timestampStr) "
                lastTimestamp = segment.timestamp
            }
            
            transcript += segment.substring + " "
        }
        
        return transcript.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

enum TranscriptionError: Error, LocalizedError {
    case notAuthorized
    case recognizerUnavailable
    
    var errorDescription: String? {
        switch self {
        case .notAuthorized: return "Speech recognition permission denied."
        case .recognizerUnavailable: return "Speech recognizer is not available for this language."
        }
    }
}
