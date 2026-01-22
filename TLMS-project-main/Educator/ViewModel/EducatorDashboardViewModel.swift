//
//  EducatorDashboardViewModel.swift
//  TLMS-project-main
//
//  ViewModel for Educator Dashboard with mock data
//

import SwiftUI
import Combine

@MainActor
class EducatorDashboardViewModel: ObservableObject {
    @Published var totalCourses: Int = 0
    @Published var totalEnrollments: Int = 0
    @Published var recentCourses: [Course] = []
    @Published var courseToDelete: Course?
    @Published var showDeleteConfirmation = false
    @Published var courseToUnpublish: Course?
    @Published var showUnpublishConfirmation = false
    
    private let courseService = CourseService()
    
    init() {
        // Initialize with default values
        totalCourses = 0
        totalEnrollments = 0
        recentCourses = []
    }
    
    var draftCourses: [Course] {
        recentCourses.filter { $0.status == .draft }
    }
    
    var otherCourses: [Course] {
        recentCourses.filter { $0.status != .draft }
    }
    
    func loadData(educatorID: UUID) async {
        let courses = await courseService.fetchCourses(for: educatorID)
        
        self.totalCourses = courses.count
        self.totalEnrollments = courses.reduce(0) { $0 + $1.enrollmentCount }
        self.recentCourses = courses
    }
    
    func deleteCourse(_ course: Course) async -> Bool {
        let success = await courseService.deleteCourse(courseID: course.id)
        if success {
            // Remove from local array
            recentCourses.removeAll { $0.id == course.id }
            totalCourses = recentCourses.count
        }
        return success
    }
    
    func confirmDelete(_ course: Course) {
        courseToDelete = course
        showDeleteConfirmation = true
    }
    
    func confirmUnpublish(_ course: Course) {
        courseToUnpublish = course
        showUnpublishConfirmation = true
    }
    
    func unpublishCourse(_ course: Course) async -> Bool {
        let success = await courseService.updateCourseStatus(courseID: course.id, status: .draft)
        if success {
            // Update local array
            if let index = recentCourses.firstIndex(where: { $0.id == course.id }) {
                recentCourses[index].status = .draft
            }
        }
        return success
    }
}
