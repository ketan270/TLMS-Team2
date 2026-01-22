//
//  EnhancedVideoPlayer.swift
//  TLMS-project-main
//
//  Enhanced video player with play button overlay and auto-completion
//

import SwiftUI
import AVKit

struct EnhancedVideoPlayer: View {
    let videoURL: URL
    let onVideoCompleted: () -> Void
    
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @State private var showPlayButton = true
    @State private var currentTime: Double = 0
    @State private var duration: Double = 0
    @State private var hasCompletedOnce = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // Video Player
            if let player = player {
                VideoPlayer(player: player)
                    .frame(height: 250)
                    .cornerRadius(12)
                    .overlay(
                        // Play button overlay (shown when paused)
                        Group {
                            if showPlayButton {
                                ZStack {
                                    // Semi-transparent background
                                    Color.black.opacity(0.4)
                                    
                                    VStack(spacing: 16) {
                                        // Large play button
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
                                                    .frame(width: 80, height: 80)
                                                    .shadow(color: .black.opacity(0.3), radius: 10)
                                                
                                                Image(systemName: "play.fill")
                                                    .font(.system(size: 32))
                                                    .foregroundColor(AppTheme.primaryBlue)
                                                    .offset(x: 3) // Optical centering
                                            }
                                        }
                                        
                                        // Tap to play hint
                                        Text("Tap to play video")
                                            .font(.subheadline)
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(Color.black.opacity(0.6))
                                            .cornerRadius(8)
                                    }
                                }
                                .transition(.opacity)
                            }
                        }
                    )
                    .onTapGesture {
                        if isPlaying {
                            player.pause()
                            withAnimation {
                                showPlayButton = true
                            }
                            isPlaying = false
                        } else {
                            player.play()
                            withAnimation {
                                showPlayButton = false
                            }
                            isPlaying = true
                        }
                    }
            } else {
                // Loading state
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppTheme.secondaryGroupedBackground)
                        .frame(height: 250)
                    
                    ProgressView()
                }
            }
        }
        .onAppear {
            setupPlayer()
        }
        .onDisappear {
            player?.pause()
            player = nil
        }
    }
    
    private func setupPlayer() {
        let newPlayer = AVPlayer(url: videoURL)
        self.player = newPlayer
        
        // Add time observer to track progress
        newPlayer.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.5, preferredTimescale: 600),
            queue: .main
        ) { time in
            currentTime = time.seconds
            
            // Get duration
            if let duration = newPlayer.currentItem?.duration.seconds,
               !duration.isNaN && !duration.isInfinite {
                self.duration = duration
                
                // Check if video is near completion (98% or more)
                let progress = currentTime / duration
                if progress >= 0.98 && !hasCompletedOnce {
                    hasCompletedOnce = true
                    handleVideoCompletion()
                }
            }
        }
        
        // Observe player reaching end
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: newPlayer.currentItem,
            queue: .main
        ) { _ in
            if !hasCompletedOnce {
                hasCompletedOnce = true
                handleVideoCompletion()
            }
            // Reset to beginning and show play button
            newPlayer.seek(to: .zero)
            withAnimation {
                showPlayButton = true
            }
            isPlaying = false
        }
    }
    
    private func handleVideoCompletion() {
        // Call the completion handler
        onVideoCompleted()
        
        // Provide haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

#Preview {
    EnhancedVideoPlayer(
        videoURL: URL(string: "https://www.youtube.com/watch?v=aircAruvnKk")!,
        onVideoCompleted: {
            print("Video completed!")
        }
    )
    .padding()
}
