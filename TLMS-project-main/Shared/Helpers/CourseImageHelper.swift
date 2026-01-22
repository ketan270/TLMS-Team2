//
//  CourseImageHelper.swift
//  TLMS-project-main
//
//  Helper to map course categories to default images
//

import Foundation
import UIKit

struct CourseImageHelper {
    // Map category to bundled image name from Assets.xcassets
    static func getDefaultImageName(for category: String) -> String {
        switch category.lowercased() {
        case "programming", "development", "code":
            return "programming"
        case "marketing":
            return "marketing"
        case "design":
            return "design"
        case "business":
            return "business"
        case "data science", "data", "analytics":
            return "data_science"
        case "photography":
            return "photography"
        case "music":
            return "music"
        default:
            return "programming" // fallback
        }
    }
    
    // Get course image with fallback to category default
    // Returns bundled image name (not URL)
    static func getCourseImage(courseCoverUrl: String?, category: String) -> String {
        // If course has a custom cover URL, return it
        // Otherwise return the bundled image name
        return courseCoverUrl ?? getDefaultImageName(for: category)
    }
}
