//
//  LearnerDashboardView.swift
//  TLMS-project-main
//
//  Dashboard for learner users
//

import SwiftUI

struct LearnerDashboardView: View {
    let user: User

    @EnvironmentObject var authService: AuthService
    @StateObject private var viewModel = LearnerDashboardViewModel()

    @State private var selectedTab: Int = 0
    @State private var searchText: String = ""
    @State private var selectedCategory: String? = nil

    var body: some View {
        TabView(selection: $selectedTab) {

            // MARK: - Browse Courses Tab
            LearnerCourseListView(
                user: user,
                title: "Browse Courses",
                courses: viewModel.browseOnlyCourses(),
                enrolledCourses: viewModel.enrolledCourses,
                isLoading: viewModel.isLoading,
                selectedSortOption: viewModel.selectedSortOption,
                selectedCategory: selectedCategory,
                searchText: searchText,
                isEnrolled: { course in
                    viewModel.enrolledCourses.contains { $0.id == course.id }
                },
                onEnroll: { course in
                    await viewModel.enroll(course: course, userId: user.id)
                },
                onSortChange: { option in
                    viewModel.selectedSortOption = option
                },
                onLogout: handleLogout
            )
            .tabItem {
                Label("Browse", systemImage: "book.fill")
            }
            .tag(0)

            // MARK: - My Courses Tab
            LearnerCourseListView(
                user: user,
                title: "My Courses",
                courses: viewModel.enrolledCourses,
                enrolledCourses: viewModel.enrolledCourses,
                isLoading: viewModel.isLoading,
                selectedSortOption: viewModel.selectedSortOption,
                selectedCategory: nil,
                searchText: searchText,
                isEnrolled: { _ in true },
                onEnroll: { _ in },
                onSortChange: { _ in }, // no sorting needed here
                onLogout: handleLogout
            )
            .tabItem {
                Label("My Courses", systemImage: "person.fill")
            }
            .tag(1)

            // MARK: - Search Tab
            LearnerSearchView(
                user: user,
                selectedCategory: $selectedCategory,
                searchText: $searchText,
                isEnrolled: { course in
                    viewModel.enrolledCourses.contains { $0.id == course.id }
                },
                enroll: { course in
                    await viewModel.enroll(course: course, userId: user.id)
                },
                handleLogout: handleLogout,
                browseOnlyCourses: viewModel.browseOnlyCourses()
            )
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }
            .tag(2)

            // MARK: - Profile Tab
            ProfileView(user: user)
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
                .tag(3)
        }
        .tint(AppTheme.primaryBlue)

        // Initial load
        .task {
            await viewModel.loadData(userId: user.id)
        }

        // Refresh after payment / return
        .onAppear {
            Task {
                await viewModel.loadData(userId: user.id)
            }
        }

        // Error handling
        .alert("Error", isPresented: $viewModel.showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Failed to enroll in course")
        }
    }

    // MARK: - Logout
    private func handleLogout() {
        Task {
            await authService.signOut()
        }
    }
}

