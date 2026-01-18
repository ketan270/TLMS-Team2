//
//  CourseFilterHelper.swift
//  TLMS-project-main
//

import Foundation

struct CourseFilterHelper {

    static func filterAndSort(
        courses: [Course],
        selectedCategory: String?,
        searchText: String,
        sortOption: CourseSortOption
    ) -> [Course] {

        var working = courses

        if let category = selectedCategory {
            working = working.filter { $0.category == category }
        }

        if !searchText.isEmpty {
            working = working.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }

        return sortCourses(working, by: sortOption, searchText: searchText)
    }

    // MARK: - Sorting

    private static func sortCourses(
        _ courses: [Course],
        by option: CourseSortOption,
        searchText: String
    ) -> [Course] {

        switch option {

        case .relevance:
            return courses.sorted {
                let lhsScore = relevanceScore(for: $0, searchText: searchText)
                let rhsScore = relevanceScore(for: $1, searchText: searchText)

                if lhsScore != rhsScore {
                    return lhsScore > rhsScore
                }

                // fallback for stable order
                return $0.createdAt > $1.createdAt
            }

        case .popularity:
            return courses.sorted {
                let lhsPopularity = $0.enrolledCount ?? 0
                let rhsPopularity = $1.enrolledCount ?? 0

                if lhsPopularity != rhsPopularity {
                    return lhsPopularity > rhsPopularity
                }

                let lhsRating = $0.rating ?? 0
                let rhsRating = $1.rating ?? 0

                if lhsRating != rhsRating {
                    return lhsRating > rhsRating
                }

                // final stable fallback
                return $0.title < $1.title
            }

        case .newest:
            return courses.sorted {
                $0.createdAt > $1.createdAt
            }
        }
    }

    // MARK: - Relevance Scoring

    private static func relevanceScore(
        for course: Course,
        searchText: String
    ) -> Int {

        guard !searchText.isEmpty else { return 0 }

        let query = searchText.lowercased()
        var score = 0

        if course.title.lowercased().contains(query) {
            score += 3
        }

        if course.description.lowercased().contains(query) {
            score += 2
        }

        if course.category.lowercased().contains(query) {
            score += 1
        }

        return score
    }
}

