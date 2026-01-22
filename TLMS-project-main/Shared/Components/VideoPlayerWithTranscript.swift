//
//  VideoPlayerWithTranscript.swift
//  TLMS-project-main
//
//  Video player with accessible transcript support
//

import SwiftUI
import AVKit

struct VideoPlayerWithTranscript: View {
    let videoURL: URL?
    let transcript: String?
    var onVideoCompleted: (() -> Void)? = nil
    
    @State private var showTranscript = true
    @State private var player: AVPlayer?
    @State private var currentTime: Double = 0
    @State private var highlightedSegmentIndex: Int? = nil
    @State private var isPlaying = false
    @State private var showPlayButton = true
    @Environment(\.colorScheme) var colorScheme
    
    // Parse transcript into segments
    private var transcriptSegments: [TranscriptSegment] {
        guard let transcript = transcript, !transcript.isEmpty else { return [] }
        return parseTranscript(transcript)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Video Player Area
            if let videoURL = videoURL, let player = player {
                ZStack {
                    VideoPlayer(player: player)
                        .frame(height: 250)
                        .cornerRadius(12)
                    
                    // Play Button Overlay
                    if showPlayButton {
                        ZStack {
                            Color.black.opacity(0.4)
                            
                            Button(action: {
                                player.play()
                                withAnimation {
                                    showPlayButton = false
                                }
                                isPlaying = true
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 70, height: 70)
                                        .shadow(radius: 10)
                                    
                                    Image(systemName: "play.fill")
                                        .font(.system(size: 30))
                                        .foregroundColor(AppTheme.primaryBlue)
                                        .offset(x: 3)
                                }
                            }
                        }
                        .cornerRadius(12)
                        .transition(.opacity)
                    }
                }
                .onTapGesture {
                    if isPlaying {
                        player.pause()
                        withAnimation { showPlayButton = true }
                        isPlaying = false
                    } else {
                        player.play()
                        withAnimation { showPlayButton = false }
                        isPlaying = true
                    }
                }
            } else {
                // Placeholder when no video
                ZStack {
                    Rectangle()
                        .fill(AppTheme.secondaryGroupedBackground)
                        .frame(height: 250)
                    
                    VStack(spacing: 12) {
                        Image(systemName: "play.slash.fill")
                            .font(.system(size: 50))
                            .foregroundColor(AppTheme.secondaryText.opacity(0.5))
                        Text("Video not available")
                            .font(.headline)
                            .foregroundColor(AppTheme.secondaryText)
                    }
                }
                .cornerRadius(12)
            }
            
            // MARK: - Controls Bar
            HStack {
                if let transcript = transcript, !transcript.isEmpty {
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            showTranscript.toggle()
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: showTranscript ? "captions.bubble.fill" : "captions.bubble")
                                .font(.system(size: 16))
                            Text(showTranscript ? "Hide Transcript" : "Show Transcript")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(showTranscript ? AppTheme.primaryBlue : AppTheme.secondaryText)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(showTranscript ? AppTheme.primaryBlue.opacity(0.1) : AppTheme.secondaryGroupedBackground)
                        .cornerRadius(8)
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            // MARK: - Transcript Panel
            if showTranscript {
                if !transcriptSegments.isEmpty {
                    // Timestamped segments
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 0) {
                                ForEach(Array(transcriptSegments.enumerated()), id: \.offset) { index, segment in
                                    TranscriptSegmentView(
                                        segment: segment,
                                        isHighlighted: highlightedSegmentIndex == index,
                                        onTap: {
                                            seekToTime(segment.timestamp)
                                        }
                                    )
                                    .id(index)
                                    
                                    if index < transcriptSegments.count - 1 {
                                        Divider()
                                            .padding(.leading, 60)
                                            .opacity(0.3)
                                    }
                                }
                            }
                        }
                        .frame(maxHeight: 250)
                        .background(AppTheme.secondaryGroupedBackground)
                        .cornerRadius(12)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .onChange(of: highlightedSegmentIndex) { oldValue, newValue in
                            if let newValue = newValue {
                                withAnimation {
                                    proxy.scrollTo(newValue, anchor: .center)
                                }
                            }
                        }
                    }
                } else if let transcript = transcript, !transcript.isEmpty {
                    // Plain text fallback
                    ScrollView {
                        Text(transcript.replacingOccurrences(of: "\\n", with: "\n"))
                            .font(.body)
                            .lineSpacing(6)
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxHeight: 250)
                    .background(AppTheme.secondaryGroupedBackground)
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                    .transition(.move(edge: .top).combined(with: .opacity))
                } else {
                    // Empty state
                    VStack(spacing: 12) {
                        Image(systemName: "text.quote")
                            .font(.system(size: 30))
                            .foregroundColor(AppTheme.secondaryText.opacity(0.5))
                        Text("No transcript available for this lesson.")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.secondaryText)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                    .background(AppTheme.secondaryGroupedBackground)
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
        }
        .onAppear {
            setupPlayer()
        }
        .onChange(of: videoURL) { oldValue, newValue in
            setupPlayer()
        }
        .onChange(of: transcript) { oldValue, newValue in
            if let newValue = newValue, !newValue.isEmpty {
                showTranscript = true
            }
        }
        .onDisappear {
            player?.pause()
            player = nil
        }
    }
    
    // MARK: - Helper Methods
    
    private func setupPlayer() {
        guard let videoURL = videoURL else { return }
        player?.pause()
        
        let playerItem = AVPlayerItem(url: videoURL)
        let newPlayer = AVPlayer(playerItem: playerItem)
        self.player = newPlayer
        
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { _ in
            onVideoCompleted?()
            withAnimation { showPlayButton = true }
            isPlaying = false
        }
        
        startTimeObserver()
        showPlayButton = true
        isPlaying = false
    }
    
    private func startTimeObserver() {
        guard let player = player else { return }
        player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.5, preferredTimescale: 600),
            queue: .main
        ) { time in
            currentTime = time.seconds
            updateHighlightedSegment()
        }
    }
    
    private func updateHighlightedSegment() {
        guard !transcriptSegments.isEmpty else { return }
        for (index, segment) in transcriptSegments.enumerated() {
            let nextSegmentTime = index < transcriptSegments.count - 1 ?
                transcriptSegments[index + 1].timestamp : Double.infinity
            if currentTime >= segment.timestamp && currentTime < nextSegmentTime {
                highlightedSegmentIndex = index
                return
            }
        }
    }
    
    private func seekToTime(_ timestamp: Double) {
        guard let player = player else { return }
        player.seek(to: CMTime(seconds: timestamp, preferredTimescale: 600))
        player.play()
    }
    
    private func parseTranscript(_ transcript: String) -> [TranscriptSegment] {
        let normalized = transcript.replacingOccurrences(of: "\\n", with: "\n")
        let lines = normalized.components(separatedBy: .newlines)
        var segments: [TranscriptSegment] = []
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty { continue }
            if let match = trimmed.range(of: #"\[(\d{1,2}:\d{2})\]"#, options: .regularExpression) {
                let timestampStr = String(trimmed[match]).trimmingCharacters(in: CharacterSet(charactersIn: "[]"))
                let text = String(trimmed[match.upperBound...]).trimmingCharacters(in: .whitespaces)
                if let timestamp = parseTimestamp(timestampStr) {
                    segments.append(TranscriptSegment(timestamp: timestamp, text: text))
                }
            }
        }
        return segments
    }
    
    private func parseTimestamp(_ str: String) -> Double? {
        let components = str.components(separatedBy: ":")
        guard components.count == 2,
              let minutes = Int(components[0]),
              let seconds = Int(components[1]) else { return nil }
        return Double(minutes * 60 + seconds)
    }
}

// MARK: - Supporting Types

struct TranscriptSegment {
    let timestamp: Double
    let text: String
    var formattedTimestamp: String {
        let minutes = Int(timestamp) / 60
        let seconds = Int(timestamp) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct TranscriptSegmentView: View {
    let segment: TranscriptSegment
    let isHighlighted: Bool
    let onTap: () -> Void
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 12) {
                Text(segment.formattedTimestamp)
                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    .foregroundColor(isHighlighted ? AppTheme.primaryBlue : AppTheme.secondaryText)
                    .frame(width: 45, alignment: .leading)
                Text(segment.text)
                    .font(.system(size: 14))
                    .foregroundColor(isHighlighted ? AppTheme.primaryText : AppTheme.secondaryText)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(12)
            .background(isHighlighted ? AppTheme.primaryBlue.opacity(0.1) : Color.clear)
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VideoPlayerWithTranscript(
        videoURL: URL(string: "https://example.com/video.mp4"),
        transcript: "[00:00] Intro\n[00:15] Part 1"
    )
    .padding()
}
