//
//  CourseEnrollmentFilter.swift
//  TLMS-project-main
//
//  Created for "My Courses" filtering
//

import Foundation

enum CourseEnrollmentFilter: String, CaseIterable, Identifiable {
    case inProgress = "In Progress"
    case completed = "Completed"
    
    var id: String { rawValue }
}
