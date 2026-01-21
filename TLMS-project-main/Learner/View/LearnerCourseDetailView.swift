//
//  LearnerCourseDetailView.swift
//  TLMS-project-main
//
//  View for Learners to preview course content and enroll
//

import SwiftUI
import Supabase
import PostgREST

struct LearnerCourseDetailView: View {
    let course: Course
    let isEnrolled: Bool
    let userId: UUID
    var onEnroll: () async -> Void

    @State private var expandedModules: Set<UUID> = []
    @State private var selectedLesson: Lesson?
    @State private var showLesson = false
    @State private var showEnrollmentAlert = false

    @State private var isEnrolling = false
    @State private var showPaymentSheet = false
    @State private var paymentURL: URL?
    @State private var currentOrderId: String?
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showCompletionPopup = false
    @State private var showCertificate = false
    @State private var isCheckingProgress = false

    @State private var reviews: [CourseReview] = []
    @State private var userReview: CourseReview?
    @State private var showReviewSubmission = false
    @State private var isCourseCompleted = false
    @StateObject private var reviewService = ReviewService()

    @StateObject private var paymentService = PaymentService()
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authService: AuthService

    var isPaidCourse: Bool {
        if let price = course.price, price > 0 {
            return true
        }
        return false
    }

    // MARK: - Body

    var body: some View {
        Group {
            if course.status != .published {
                CourseNotAvailableView()
            } else {
                mainContent
            }
        }
    }

    // MARK: - Main Content

    private var mainContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                courseContentSection
                reviewsSection
                Spacer(minLength: 80)
            }
            .padding(.top)
        }
        .background(AppTheme.groupedBackground)
        .navigationTitle("Course Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if isEnrolled {
                checkForCompletion()
            }
            fetchReviews()
        }
        .fullScreenCover(isPresented: $showCompletionPopup, content: completionPopupContent)
        .fullScreenCover(isPresented: $showCertificate, content: certificateContent)
        .sheet(isPresented: $showReviewSubmission, content: reviewSubmissionContent)
        .navigationDestination(isPresented: $showLesson) {
            lessonDestination
        }
        .safeAreaInset(edge: .bottom) {
            if !isEnrolled {
                enrollmentBottomBar
            }
        }
        .sheet(isPresented: $showPaymentSheet, content: paymentSheetContent)
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .alert("Enrollment Required", isPresented: $showEnrollmentAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Enroll Now") {}
        } message: {
            Text("Please enroll in this course to access the lesson content.")
        }
    }
    
    // MARK: - Extracted Views
    
    @ViewBuilder
    private func completionPopupContent() -> some View {
        CourseCompletionView(
            course: course,
            userId: userId,
            onDismiss: { showCompletionPopup = false },
            onViewCertificate: {
                showCompletionPopup = false
                showCertificate = true
            }
        )
    }
    
    @ViewBuilder
    private func certificateContent() -> some View {
        NavigationView {
            CertificatesListView(userId: userId)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Close") {
                            showCertificate = false
                        }
                    }
                }
        }
    }
    
    @ViewBuilder
    private func reviewSubmissionContent() -> some View {
        ReviewSubmissionView(
            course: course,
            userId: userId,
            existingReview: userReview,
            onSubmissionSuccess: {
                fetchReviews()
            }
        )
    }
    
    @ViewBuilder
    private func paymentSheetContent() -> some View {
        if let url = paymentURL {
            PaymentWebView(
                paymentURL: url,
                onSuccess: { paymentId in
                    Task {
                        await handlePaymentSuccess(paymentId: paymentId)
                    }
                },
                onFailure: {
                    errorMessage = "Payment was cancelled or failed"
                    showError = true
                }
            )
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Course")
                        .font(.caption)
                        .foregroundColor(AppTheme.secondaryText)
                    Text(course.category)
                        .font(.subheadline.bold())
                        .foregroundColor(AppTheme.primaryBlue)
                        .lineLimit(1)
                }

                Spacer()

                if isEnrolled {
                    Label("Enrolled", systemImage: "checkmark.circle.fill")
                        .font(.caption.bold())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(AppTheme.successGreen.opacity(0.1))
                        .foregroundColor(AppTheme.successGreen)
                        .cornerRadius(8)
                } else if isPaidCourse, let price = course.price {
                    Text(price.formatted(.currency(code: "INR")))
                        .font(.title3.bold())
                        .foregroundColor(AppTheme.primaryBlue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(AppTheme.primaryBlue.opacity(0.1))
                        .cornerRadius(8)
                }
            }

            Divider()

            Text(course.title)
                .font(.title2.bold())
                .foregroundColor(AppTheme.primaryText)

            Text(course.description)
                .font(.body)
                .foregroundColor(AppTheme.secondaryText)

            HStack(spacing: 16) {
                Label("\(course.modules.count) Modules", systemImage: "book.fill")

                if let enrolledCount = course.enrolledCount {
                    Label("\(enrolledCount) Students", systemImage: "person.2.fill")
                }

                if let rating = course.ratingAvg, course.ratingCount > 0 {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.orange)
                        Text(String(format: "%.1f", rating))
                        Text("(\(course.ratingCount))")
                            .foregroundColor(AppTheme.secondaryText)
                    }
                } else {
                    Text("No ratings yet").italic()
                }
            }
            .font(.caption)
            .foregroundColor(AppTheme.secondaryText)
        }
        .padding()
        .background(AppTheme.secondaryGroupedBackground)
        .cornerRadius(16)
        .padding(.horizontal)
    }

    // MARK: - Course Content Section

    private var courseContentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Course Content")
                .font(.title3.bold())
                .padding(.horizontal)

            if course.modules.isEmpty {
                Text("No content available yet.")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.secondaryText)
                    .padding(.horizontal)
            } else {
                ForEach(Array(course.modules.enumerated()), id: \.element.id) { index, module in
                    ModulePreviewCard(
                        module: module,
                        moduleNumber: index + 1,
                        isExpanded: expandedModules.contains(module.id),
                        isEnrolled: isEnrolled,
                        onToggle: {
                            withAnimation {
                                expandedModules.toggle(module.id)
                            }
                        },
                        onLessonTap: { lesson in
                            if isEnrolled {
                                selectedLesson = lesson
                                showLesson = true
                            } else {
                                showEnrollmentAlert = true
                            }
                        }
                    )
                }
            }
        }
    }

    // MARK: - Reviews Section

    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Ratings & Reviews")
                    .font(.title3.bold())

                Spacer()

                if isEnrolled && canSubmitReview {
                    Button {
                        showReviewSubmission = true
                    } label: {
                        Text(userReview == nil ? "Write a Review" : "Edit Review")
                            .font(.subheadline.bold())
                            .foregroundColor(AppTheme.primaryBlue)
                    }
                }
            }
            .padding(.horizontal)

            if reviews.isEmpty {
                Text("No reviews yet. Be the first to share your experience!")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.secondaryText)
                    .padding(.horizontal)
            } else {
                ForEach(reviews) { review in
                    ReviewRow(review: review)
                        .padding(.horizontal)
                }
            }
        }
    }

    // MARK: - Lesson Destination

    private var lessonDestination: some View {
        Group {
            if let lesson = selectedLesson {
                if lesson.type == .quiz {
                    LearnerQuizView(
                        lesson: lesson, isPresented: $showLesson
                    )
                } else {
                    LessonContentView(
                        lesson: lesson,
                        course: course,
                        userId: userId,
                        selectedLesson: $selectedLesson
                    )
                }
            }
        }
    }

    // MARK: - Enrollment Bottom Bar

    private var enrollmentBottomBar: some View {
        VStack {
            Divider()
            Button(action: handleEnrollmentAction) {
                HStack {
                    if isEnrolling || paymentService.isLoading {
                        ProgressView().tint(.white)
                    } else if isPaidCourse, let price = course.price {
                        Label("Buy Now - \(price.formatted(.currency(code: "INR")))", systemImage: "cart.fill")
                    } else {
                        Label("Enroll Free", systemImage: "checkmark.circle.fill")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppTheme.primaryBlue)
                .foregroundColor(.white)
                .cornerRadius(AppTheme.cornerRadius)
            }
            .disabled(isEnrolling || paymentService.isLoading)
            .padding()
        }
    }

    // MARK: - Actions (UNCHANGED)

    private func handleEnrollmentAction() {
        if isPaidCourse {
            Task { await initiatePayment() }
        } else {
            Task {
                isEnrolling = true
                await onEnroll()
                isEnrolling = false
                dismiss()
            }
        }
    }

    private func initiatePayment() async {
        guard let price = course.price,
              let user = authService.currentUser else { return }

        if let order = await paymentService.createPaymentOrder(
            courseId: course.id,
            userId: userId,
            amount: price
        ) {
            currentOrderId = order.orderId
            if let url = paymentService.getPaymentURL(
                order: order,
                userEmail: user.email,
                userName: user.fullName
            ) {
                paymentURL = url
                showPaymentSheet = true
            }
        }
    }

    private func handlePaymentSuccess(paymentId: String) async {
        guard let orderId = currentOrderId else { return }
        let success = await paymentService.verifyPayment(
            orderId: orderId,
            paymentId: paymentId,
            courseId: course.id,
            userId: userId
        )
        if success { dismiss() }
    }

    private func checkForCompletion() {
        Task {
            let supabase = SupabaseManager.shared.client
            struct ProgressCheck: Codable { let progress: Double? }

            let result: [ProgressCheck] = try await supabase
                .from("enrollments")
                .select("progress")
                .eq("user_id", value: userId)
                .eq("course_id", value: course.id)
                .execute()
                .value

            if let progress = result.first?.progress, progress >= 1.0 {
                showCompletionPopup = true
            }
        }
    }

    private var canSubmitReview: Bool { true }

    private func fetchReviews() {
        Task {
            reviews = await reviewService.fetchReviews(for: course.id)
            userReview = await reviewService.fetchUserReview(courseID: course.id, userID: userId)
        }
    }
}

// MARK: - Helper

private extension Set where Element == UUID {
    mutating func toggle(_ id: UUID) {
        if contains(id) {
            remove(id)
        } else {
            insert(id)
        }
    }
}

