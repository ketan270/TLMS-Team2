//
//  LearnerDashboardView.swift
//  TLMS-project-main
//
//  Dashboard for learner users
//

import SwiftUI
import Supabase

struct LearnerDashboardView: View {
    let user: User
    @EnvironmentObject var authService: AuthService
    @StateObject private var viewModel = LearnerDashboardViewModel()
    @State private var selectedTab = 0
    @State private var dashboardRefreshTrigger = UUID()
    @State private var isRefreshing = false
    @StateObject private var chatViewModel = ChatViewModel()
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) { // Use ZStack for overlay
            TabView(selection: $selectedTab) {
                // Browse Courses Tab
                courseListView(courses: viewModel.publishedCourses.filter { course in
                    !viewModel.isEnrolled(course)
                }, title: "Browse Courses", showSearch: false)
                .id(dashboardRefreshTrigger)
                .tabItem {
                    Label("Browse", systemImage: "book.fill")
                }
                .tag(0)
                
                // My Courses Tab
                courseListView(
                    courses: viewModel.enrolledCourses,
                    title: "My Courses",
                    showSearch: false
                )
                .id(dashboardRefreshTrigger)
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
                        Label("Profile", systemImage: "person.fill")
                    }
                    .tag(3)
            }
            .tint(AppTheme.primaryBlue)
            .task {
                await viewModel.loadData(userId: user.id)
            }
            
            // 🔥 Gemini Chatbot Overlay
            if chatViewModel.isChatOpen {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation { chatViewModel.isChatOpen = false }
                    }
                
                ChatView(viewModel: chatViewModel)
                    .frame(height: 500)
                    .padding()
                    .padding(.bottom, 80) // Above TabBar
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(2)
            }
            
            // Floating Button
            FloatingChatButton(viewModel: chatViewModel)
                .padding(.bottom, 90) // Above TabBar
                .padding(.trailing, 20)
                .zIndex(3)
        }
        .onReceive(
            NotificationCenter.default.publisher(for: .courseProgressUpdated)
        ) { _ in
            dashboardRefreshTrigger = UUID()   // 🔥 THIS LINE WAS MISSING
            Task {
                await viewModel.loadData(userId: user.id)
            }
        }
        .onReceive(
            NotificationCenter.default.publisher(for: .courseEnrolled)
        ) { _ in
            dashboardRefreshTrigger = UUID()
            Task {
                await viewModel.loadData(userId: user.id)
            }
            // Switch to "My Courses" tab to show newly enrolled course
            selectedTab = 1
        }
        .alert("Error", isPresented: $viewModel.showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "Failed to enroll in course")
        }
    }
    
    // MARK: - Search View
    
    @ViewBuilder
    private func searchView() -> some View {
        NavigationStack {
            ZStack {
                AppTheme.groupedBackground
                    .ignoresSafeArea(edges: .top)
                
                VStack(spacing: 0) {
                    // Category Grid (Apple TV style)
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 16) {
                            ForEach(CourseCategories.all, id: \.self) { category in
                                NavigationLink(destination: CategoryCoursesView(
                                    category: category,
                                    courses: viewModel.publishedCourses.filter { $0.category == category },
                                    userId: user.id
                                )) {
                                    CategoryCard(
                                        title: category,
                                        icon: iconForCategory(category),
                                        color: colorForCategory(category)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                        .padding(.bottom, 80) // Space for search bar
                    }
                }
            }
            .navigationTitle("Course Category")
            .navigationBarTitleDisplayMode(.large)
        }
        .id(user.id)
    }
    
    @ViewBuilder
    private func courseListView(courses: [Course], title: String, showSearch: Bool) -> some View {
        NavigationStack {
            ZStack {
                AppTheme.groupedBackground
                    .ignoresSafeArea(edges: .top)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Welcome header
                        VStack(alignment: .leading, spacing: 8) {
                            Text(isFirstTimeUser ? "Welcome," : "Welcome back,")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            Text(user.fullName)
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, 20)
                        
                        // Quick stats
                        HStack(spacing: 16) {
                            StatCard(
                                icon: "book.fill",
                                title: "Enrolled",
                                value: "\(viewModel.enrolledCourses.count)",
                                color: AppTheme.primaryBlue
                            )
                            
                            StatCard(
                                icon: "checkmark.seal.fill",
                                title: "Completed",
                                value: "\(viewModel.completedCoursesCount)",
                                color: AppTheme.successGreen
                            )
                        }
                        .padding(.horizontal)
                        
                        // 1. Browse Courses -> Sort by goes here (below stats)
                        if title != "My Courses" {
                            sortFilterView(title: title)
                        }
                        
                        // ✅ Upcoming Deadlines
                        if title == "My Courses" {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Upcoming Deadlines")
                                        .font(.title3.bold())
                                        .foregroundColor(AppTheme.primaryText)
                                    
                                    Spacer()
                                    
                                    if viewModel.upcomingDeadlines.isEmpty {
                                        Text("No deadlines")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.horizontal)
                                
                                if viewModel.upcomingDeadlines.isEmpty {
                                    LearnerEmptyState(
                                        icon: "calendar",
                                        title: "No upcoming deadlines",
                                        message: "You're all caught up 🎉"
                                    )
                                    .padding(.horizontal)
                                } else {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 12) {
                                            ForEach(viewModel.upcomingDeadlines) { deadline in
                                                DeadlineCard(deadline: deadline)
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }
                            .padding(.top, 6)
                            
                            // 2. My Courses -> Filter by goes here (below deadlines)
                            sortFilterView(title: title)
                        }
                        
                        // Course List
                        VStack(alignment: .leading, spacing: 16) {
                            Text(title)
                                .font(.title2.bold())
                                .foregroundColor(AppTheme.primaryText)
                                .padding(.horizontal)
                            
                            if viewModel.isLoading {
                                ProgressView()
                                    .padding()
                            } else {
                                let filteredCourses = getFilteredAndSortedCourses(from: courses, isMyCourses: title == "My Courses")
                                
                                if filteredCourses.isEmpty {
                                    LearnerEmptyState(
                                        icon: viewModel.searchText.isEmpty && viewModel.selectedCategory == nil ? "book.closed.fill" : "magnifyingglass",
                                        title: viewModel.searchText.isEmpty && viewModel.selectedCategory == nil ?
                                        (title == "Browse Courses" ? "No courses available" : "No enrollments yet") :
                                            "No courses found",
                                        message: viewModel.searchText.isEmpty && viewModel.selectedCategory == nil ?
                                        (title == "Browse Courses" ? "Check back later for new content" : "Browse available courses to start learning") :
                                            "Try adjusting your search or filters"
                                    )
                                    .padding(.horizontal)
                                } else {
                                    LazyVStack(spacing: 16) {
                                        ForEach(filteredCourses) { course in
                                            NavigationLink(destination:
                                                            LearnerCourseDetailView(
                                                                course: course,
                                                                isEnrolled: viewModel.isEnrolled(course),
                                                                userId: user.id,
                                                                onEnroll: {
                                                                    let success = await viewModel.enroll(course: course, userId: user.id)
                                                                    if success {
                                                                        dashboardRefreshTrigger = UUID()
                                                                        selectedTab = 1
                                                                    }
                                                                }
                                                            )
                                            ) {
                                                PublishedCourseCard(
                                                    course: course,
                                                    isEnrolled: viewModel.isEnrolled(course),
                                                    progress: viewModel.getCachedProgress(for: course.id),
                                                    onEnroll: {
                                                        let success = await viewModel.enroll(course: course, userId: user.id)
                                                        if success {
                                                            dashboardRefreshTrigger = UUID()
                                                            selectedTab = 1
                                                        }
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
                    }
                    .padding(.bottom, 100) // Large padding for tab bar
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            isRefreshing = true
                            dashboardRefreshTrigger = UUID()
                            await viewModel.loadData(userId: user.id)
                            try? await Task.sleep(nanoseconds: 500_000_000)
                            isRefreshing = false
                        }
                    }) {
                        if isRefreshing {
                            ProgressView()
                                .tint(AppTheme.primaryBlue)
                        } else {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppTheme.primaryBlue)
                        }
                    }
                    .disabled(isRefreshing)
                }
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 0)
            }
        }
        .id(user.id)
    }
    
    // Helper to determine if user is first-time
    private var isFirstTimeUser: Bool {
        // Check if user was created recently (within last 5 minutes)
        let fiveMinutesAgo = Date().addingTimeInterval(-300)
        return user.createdAt > fiveMinutesAgo
    }
    
    @ViewBuilder
    private func sortFilterView(title: String) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                Text(title == "My Courses" ? "Filter by" : "Sort by")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.secondary)
                
                if title == "My Courses" {
                    ForEach(CourseEnrollmentFilter.allCases) { filter in
                        Button(action: {
                            withAnimation {
                                viewModel.selectedEnrollmentFilter = filter
                            }
                        }) {
                            Text(filter.rawValue)
                                .font(.system(size: 14, weight: .medium))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(
                                    viewModel.selectedEnrollmentFilter == filter ?
                                    AppTheme.primaryBlue : Color.clear
                                )
                                .foregroundColor(
                                    viewModel.selectedEnrollmentFilter == filter ?
                                        .white : AppTheme.primaryBlue
                                )
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(AppTheme.primaryBlue, lineWidth: viewModel.selectedEnrollmentFilter == filter ? 0 : 1.5)
                                )
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                } else {
                    ForEach(CourseSortOption.allCases) { option in
                        Button(action: {
                            withAnimation {
                                viewModel.selectedSortOption = option
                            }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: option.icon)
                                    .font(.system(size: 12))
                                Text(option.displayName)
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                viewModel.selectedSortOption == option ?
                                AppTheme.primaryBlue :
                                    Color.clear
                            )
                            .foregroundColor(
                                viewModel.selectedSortOption == option ?
                                    .white :
                                    AppTheme.primaryBlue
                            )
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(AppTheme.primaryBlue, lineWidth: viewModel.selectedSortOption == option ? 0 : 1.5)
                            )
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal)
        }
        .frame(height: 44)
        .zIndex(10) // Ensure it's above any other content
        .allowsHitTesting(true)
    }
    
    private func handleLogout() {
        Task {
            await authService.signOut()
        }
    }
    
    // Helper function (brought back from original to support filtering for both tabs)
    private func getFilteredAndSortedCourses(from courses: [Course], isMyCourses: Bool = false) -> [Course] {
        // 1. Apply search filter
        var filtered = courses
        if !viewModel.searchText.isEmpty {
            filtered = filtered.filter { course in
                course.title.localizedCaseInsensitiveContains(viewModel.searchText) ||
                course.description.localizedCaseInsensitiveContains(viewModel.searchText)
            }
        }
        
        // 2. Apply category filter
        if let category = viewModel.selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
        
        // 3. Apply Enrollment Filter if in "My Courses" tab
        if isMyCourses {
            filtered = viewModel.filteredEnrolledCourses.filter { enrolled in
                // Cross-reference with basic filters (search/category) applied above
                filtered.contains(where: { $0.id == enrolled.id })
            }
            return filtered // For "My Courses", we prioritize the enrollment filter
        }
        
        // 4. Apply sorting (Default for Browse tab)
        switch viewModel.selectedSortOption {
        case .relevance:
            // Sort by relevance: prioritize courses matching completed course categories/educators
            return filtered.sorted { course1, course2 in
                let score1 = relevanceScore(for: course1)
                let score2 = relevanceScore(for: course2)
                
                if score1 != score2 {
                    return score1 > score2 // Higher score first
                }
                // If same relevance score, sort by newest
                return course1.createdAt > course2.createdAt
            }
            
        case .popularity:
            // Sort by enrollment count (descending)
            print("DEBUG: Sorting by popularity")
            for course in filtered.prefix(5) {
                print("  - \(course.title): enrollmentCount=\(course.enrollmentCount)")
            }
            return filtered.sorted { course1, course2 in
                let count1 = course1.enrollmentCount
                let count2 = course2.enrollmentCount
                
                if count1 != count2 {
                    return count1 > count2
                }
                // If same enrollment count, sort by newest
                return course1.createdAt > course2.createdAt
            }
            
        case .newest:
            // Sort by creation date (newest first)
            print("DEBUG: Sorting by newest")
            for course in filtered.prefix(5) {
                print("  - \(course.title): createdAt=\(course.createdAt)")
            }
            return filtered.sorted { $0.createdAt > $1.createdAt }
        }
    }
    
    // Calculate relevance score based on completed courses
    private func relevanceScore(for course: Course) -> Int {
        var score = 0
        
        // +2 points if course category matches completed course categories
        if viewModel.completedCourseCategories.contains(course.category) {
            score += 2
        }
        
        // +1 point if course educator matches completed course educators
        if viewModel.completedCourseEducators.contains(course.educatorID) {
            score += 1
        }
        
        return score
    }
    
    private func iconForCategory(_ category: String) -> String {
        switch category {
        case "Programming": return "chevron.left.forwardslash.chevron.right"
        case "Design": return "paintbrush.fill"
        case "Business": return "briefcase.fill"
        case "Data Science": return "chart.bar.fill"
        case "Marketing": return "megaphone.fill"
        case "Photography": return "camera.fill"
        case "Music": return "music.note"
        case "Writing": return "pencil.and.outline"
        default: return "book.fill"
        }
    }
    
    // MARK: - Published Course Card
    
    // Unified handleEnrollment function for the view to use
    private func handleEnrollment(for course: Course) async {
        _ = await viewModel.enroll(course: course, userId: user.id)
        // Refresh trigger handles the UI update
    }
    
    
    //
    //        private func loadProgress() {
    //            Task {
    //                courseProgress = await getCourseProgress(userId: userId, courseId: course.id)
    //                print("📊 Loaded progress for \(course.title): \(courseProgress * 100)%")
    //            }
    //        }
    //
    //        private func getCourseProgress(userId: UUID, courseId: UUID) async -> Double {
    //            do {
    //                let supabase = SupabaseManager.shared.client
    //
    //                // Fetch enrollment to get progress
    //                struct EnrollmentProgress: Codable {
    //                    let progress: Double?
    //                }
    //
    //                let enrollments: [EnrollmentProgress] = try await supabase
    //                    .from("enrollments")
    //                    .select("progress")
    //                    .eq("user_id", value: userId.uuidString)
    //                    .eq("course_id", value: courseId.uuidString)
    //                    .execute()
    //                    .value
    //
    //                return enrollments.first?.progress ?? 0.0
    //            } catch {
    //                print("❌ Error fetching progress: \(error)")
    //                return 0.0
    //            }
    //        }
    
    // Components are defined in separate files (LearnerDashboardComponents.swift, StatCard.swift, etc.)
    
    private func colorForCategory(_ category: String) -> Color {
        switch category {
        case "Programming": return Color(red: 0.2, green: 0.6, blue: 1.0)
        case "Design": return Color(red: 1.0, green: 0.4, blue: 0.6)
        case "Business": return Color(red: 0.4, green: 0.8, blue: 0.4)
        case "Marketing": return Color(red: 1.0, green: 0.6, blue: 0.2)
        case "Data Science": return Color(red: 0.6, green: 0.4, blue: 1.0)
        default: return AppTheme.primaryBlue
        }
    }
}
