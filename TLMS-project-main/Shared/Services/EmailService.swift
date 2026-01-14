//
//  EmailService.swift
//  TLMS-project-main
//
//  Service for sending automated emails.
//  Currently runs as a stub/mock since no backend email provider is configured.
//

import Foundation

class EmailService {
    static let shared = EmailService()
    
    private init() {}
    
    func sendRemovalNotification(to email: String, courseTitle: String, reason: String) async -> Bool {
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1 * 1_000_000_000) // 1 second
        
        print("--------------------------------------------------")
        print("[EmailService] Sending Email to: \(email)")
        print("[EmailService] Subject: Course Removed: \(courseTitle)")
        print("[EmailService] Body:")
        print("Dear Educator,")
        print("Your course '\(courseTitle)' has been removed from the platform.")
        print("Reason: \(reason)")
        print("Please contact support if you have questions.")
        print("--------------------------------------------------")
        
        return true
    }
}
