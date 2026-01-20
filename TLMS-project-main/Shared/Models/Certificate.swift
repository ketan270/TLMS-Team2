//
//  Certificate.swift
//  TLMS-project-main
//
//  Certificate model for course completion
//

import Foundation

struct Certificate: Codable, Identifiable, Hashable {
    let id: UUID
    let userId: UUID
    let courseId: UUID
    let userName: String
    let courseName: String
    let completionDate: Date
    let certificateNumber: String
    let instructorName: String
    let createdAt: Date
    
    init(
        id: UUID = UUID(),
        userId: UUID,
        courseId: UUID,
        userName: String,
        courseName: String,
        completionDate: Date = Date(),
        certificateNumber: String,
        instructorName: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.courseId = courseId
        self.userName = userName
        self.courseName = courseName
        self.completionDate = completionDate
        self.certificateNumber = certificateNumber
        self.instructorName = instructorName
        self.createdAt = createdAt
    }
    
    var formattedCompletionDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: completionDate)
    }
    
    static func generateCertificateNumber() -> String {
        let timestamp = Int(Date().timeIntervalSince1970)
        let random = Int.random(in: 1000...9999)
        return "TLMS-\(timestamp)-\(random)"
    }
}

// MARK: - Database Model

extension Certificate {
    struct DatabaseModel: Codable {
        let id: UUID
        let user_id: UUID
        let course_id: UUID
        let user_name: String
        let course_name: String
        let completion_date: String
        let certificate_number: String
        let instructor_name: String
        let created_at: String
        
        func toCertificate() -> Certificate {
            let dateFormatter = ISO8601DateFormatter()
            
            return Certificate(
                id: id,
                userId: user_id,
                courseId: course_id,
                userName: user_name,
                courseName: course_name,
                completionDate: dateFormatter.date(from: completion_date) ?? Date(),
                certificateNumber: certificate_number,
                instructorName: instructor_name,
                createdAt: dateFormatter.date(from: created_at) ?? Date()
            )
        }
    }
}
