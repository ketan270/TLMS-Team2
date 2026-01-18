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
   
    @State private var selectedTab = 0 // 0: Browse, 1: My Courses
    @State private var searchText: String = ""
    @State private var selectedCategory: String? = nil
    
    @State private var showProfile = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Browse Courses Tab
            courseListView(courses: publishedCourses, title: "Browse Courses", showSearch: false)
                .tabItem {
                    Label("Browse", systemImage: "book.fill")
                }
                .tag(0)
            
            // My Courses Tab
            courseListView(courses: enrolledCourses, title: "My Courses", showSearch: false)
                .tabItem {
                    Label("My Courses", systemImage: "person.fill")
                }
                .tag(1)
            
            // Search Tab
            searchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(2)
            
            // Profile Tab
            ProfileView(user: user)
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
                .tag(3)

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
        }
        .tint(AppTheme.primaryBlue)
        .task {
            await viewModel.loadData(userId: user.id)
        }
        .alert("Error", isPresented: $viewModel.showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Failed to enroll in course")
        }
    }
    
    // MARK: - Logout (still belongs to the View)
    private func handleLogout() {
        Task {
            await authService.signOut()
        }
    }
}

