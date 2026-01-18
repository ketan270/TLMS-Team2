//
//  LearnerCourseListView.swift
//  TLMS-project-main
//
//  Created by Chehak on 16/01/26.
//

import SwiftUI

struct LearnerCourseListView: View {
    let user: User
    let title: String
    let courses: [Course]
    let enrolledCourses: [Course]
    let isLoading: Bool
    let selectedSortOption: CourseSortOption
    let selectedCategory: String?
    let searchText: String

    let isEnrolled: (Course) -> Bool
    let onEnroll: (Course) async -> Void
    let onSortChange: (CourseSortOption) -> Void
    let onLogout: () -> Void

    var body: some View {

        // PRE-COMPUTE FILTERED COURSES
        let filteredCourses = CourseFilterHelper.filterAndSort(
            courses: courses,
            selectedCategory: selectedCategory,
            searchText: searchText,
            sortOption: selectedSortOption
        )

        NavigationStack {
            ZStack {
                AppTheme.groupedBackground
                    .ignoresSafeArea(edges: .top)

                ScrollView {
                    VStack(spacing: 20) {

                        // MARK: - Header
                        LearnerDashboardHeader(
                            user: user,
                            enrolledCount: enrolledCourses.count
                        )

                        // MARK: - Sort Options (Browse only)
                        if title == "Browse Courses" {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(CourseSortOption.allCases, id: \.self) { option in
                                        SortOptionButton(
                                            option: option,
                                            isSelected: selectedSortOption == option,
                                            action: {
                                                onSortChange(option)
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }

                        // MARK: - Course List
                        VStack(alignment: .leading, spacing: 16) {
                            Text(title)
                                .font(.title2.bold())
                                .padding(.horizontal)

                            if isLoading {
                                ProgressView()
                                    .padding()
                            } else if filteredCourses.isEmpty {
                                LearnerEmptyState(
                                    icon: "book.closed.fill",
                                    title: "No courses found",
                                    message: "Try adjusting your filters"
                                )
                                .padding(.horizontal)
                            } else {
                                LazyVStack(spacing: 16) {
                                    ForEach(filteredCourses) { course in
                                        NavigationLink(
                                            destination:
                                                LearnerCourseDetailView(
                                                    course: course,
                                                    isEnrolled: isEnrolled(course),
                                                    userId: user.id,
                                                    onEnroll: {
                                                        await onEnroll(course)
                                                    },
                                                    onPaymentSuccess: {
                                                        // no-op
                                                        // dashboard refresh handled elsewhere
                                                    }
                                                )
                                        ) {
                                            PublishedCourseCard(
                                                course: course,
                                                isEnrolled: isEnrolled(course),
                                                onEnroll: {
                                                    await onEnroll(course)
                                                }
                                            )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
        }
        .id(user.id)
    }
}

