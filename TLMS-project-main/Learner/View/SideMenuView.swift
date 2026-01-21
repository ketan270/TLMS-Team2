//
//  SideMenuView.swift
//  TLMS-project-main
//
//  Created by Chehak on 20/01/26.
//

import Foundation
import SwiftUI

// MARK: - Side Menu (Sidebar)
struct SideMenuView: View {
    let course: Course
    let completedLessonIds: Set<UUID>

    @Binding var selectedLesson: Lesson?
    @Binding var isPresented: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Header
            Text("Course Content")
                .font(.title2.bold())
                .padding()
                .padding(.top, 50) // safe area

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    
                    // We need to flatten lessons to determine the "next unlocked" lesson logic linearly
                    // But here we iterate modules.
                    // Logic: A lesson is LOCKED unless:
                    // 1. It is completed.
                    // 2. OR it is the FIRST lesson that is NOT completed (the current active head).
                    
                    let flatLessons = course.modules.flatMap { $0.lessons }
                    let firstUncompletedId = flatLessons.first(where: { !completedLessonIds.contains($0.id) })?.id

                    ForEach(Array(course.modules.enumerated()), id: \.element.id) { index, module in

                        // MARK: - Module Section
                        VStack(alignment: .leading, spacing: 0) {

                            let moduleCompleted = module.lessons.allSatisfy {
                                completedLessonIds.contains($0.id)
                            }

                            // Module Header
                            HStack {
                                Text("Module \(index + 1): \(module.title)")
                                    .font(.headline)

                                Spacer()

                                if moduleCompleted {
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundColor(AppTheme.successGreen)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(AppTheme.secondaryGroupedBackground)

                            // MARK: - Lessons
                            ForEach(module.lessons) { lesson in

                                let isCompleted = completedLessonIds.contains(lesson.id)
                                let isCurrent = selectedLesson?.id == lesson.id
                                // Unlock if it's completed OR it's the very next one
                                let isUnlocked = isCompleted || (lesson.id == firstUncompletedId)

                                Button {
                                    if isUnlocked {
                                        selectedLesson = lesson
                                        withAnimation {
                                            isPresented = false
                                        }
                                    }
                                } label: {
                                    HStack(spacing: 12) {

                                        // Icon
                                        if isCompleted {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(AppTheme.successGreen)
                                        } else if isUnlocked {
                                            Image(systemName: lesson.type.icon)
                                                .foregroundColor(isCurrent ? .white : AppTheme.primaryAccent)
                                        } else {
                                            Image(systemName: "lock.fill")
                                                .foregroundColor(AppTheme.secondaryText)
                                        }

                                        Text(lesson.title)
                                            .font(.subheadline)
                                            .lineLimit(1)
                                            .foregroundColor(isUnlocked ? (isCurrent ? .white : AppTheme.primaryText) : AppTheme.secondaryText)

                                        Spacer()

                                        if isCurrent {
                                            Image(systemName: "chevron.right")
                                                .font(.caption)
                                        }
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 12)
                                    .background(
                                        isCurrent
                                            ? AppTheme.primaryBlue
                                            : Color.clear
                                    )
                                    .contentShape(Rectangle()) // Make full row tappable
                                }
                                .buttonStyle(.plain)
                                .disabled(!isUnlocked)

                                Divider()
                                    .padding(.leading)
                            }
                        }
                    }
                }
            }
        }
        .background(AppTheme.groupedBackground)
        .ignoresSafeArea()
    }
}
