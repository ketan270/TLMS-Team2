//
//  CourseStructureView.swift
//  TLMS-project-main
//
//  Step 2: Course Structure (Modules)
//

import SwiftUI

struct CourseStructureView: View {
    @ObservedObject var viewModel: CourseCreationViewModel
    @State private var isEditingModuleID: UUID?
    @State private var editingTitle = ""
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(viewModel.newCourse.title)
                            .font(.system(size: 28, weight: .bold))
                        
                        Text("Organize your course into modules. Add lessons within each module.")
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Modules List
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Modules")
                                .font(.title2.bold())
                            
                            Spacer()
                            
                            Button(action: { viewModel.addModule() }) {
                                Label("Add Module", systemImage: "plus")
                                    .font(.subheadline.bold())
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)
                        
                        if viewModel.newCourse.modules.isEmpty {
                            EmptyStateView(
                                icon: "folder.badge.plus",
                                title: "No Modules Yet",
                                message: "Create a module to start organizing your content."
                            )
                        } else {
                            ForEach(viewModel.newCourse.modules) { module in
                                ModuleRow(
                                    module: module,
                                    isEditing: isEditingModuleID == module.id,
                                    editingText: $editingTitle,
                                    onEditStart: {
                                        editingTitle = module.title
                                        isEditingModuleID = module.id
                                    },
                                    onEditEnd: {
                                        if !editingTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                            var updatedModule = module
                                            updatedModule.title = editingTitle
                                            viewModel.updateModule(updatedModule)
                                        }
                                        isEditingModuleID = nil
                                    },
                                    onDelete: {
                                        if let index = viewModel.newCourse.modules.firstIndex(where: { $0.id == module.id }) {
                                            viewModel.deleteModule(at: IndexSet(integer: index))
                                        }
                                    }
                                )
                                // Navigation to Module Detail
                                .background(
                                    NavigationLink(destination: ModuleDetailView(viewModel: viewModel, moduleID: module.id)) {
                                        EmptyView()
                                    }
                                    .opacity(0)
                                )
                            }
                            .onMove { source, destination in
                                viewModel.moveModule(from: source, to: destination)
                            }
                        }
                    }
                    .padding(.bottom, 20)
                    
                    // Publish Button
                    Button(action: {
                        viewModel.publishCourse()
                        // In a real app, we would probably navigate back to dashboard or show success message
                        dismiss()
                    }) {
                        Text("Publish Course")
                            .font(.system(size: 18, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                viewModel.newCourse.modules.isEmpty ?
                                LinearGradient(colors: [.gray.opacity(0.5), .gray.opacity(0.5)], startPoint: .leading, endPoint: .trailing) :
                                LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
                            )
                            .foregroundColor(.white)
                            .cornerRadius(16)
                            .shadow(color: viewModel.newCourse.modules.isEmpty ? .clear : .purple.opacity(0.3), radius: 10, y: 5)
                    }
                    .disabled(viewModel.newCourse.modules.isEmpty)
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle(viewModel.newCourse.title)
    }
}

// MARK: - Subviews

struct ModuleRow: View {
    let module: Module
    var isEditing: Bool
    @Binding var editingText: String
    var onEditStart: () -> Void
    var onEditEnd: () -> Void
    var onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                if isEditing {
                    TextField("Module Name", text: $editingText, onCommit: onEditEnd)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                } else {
                    Text(module.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                if isEditing {
                    Button(action: onEditEnd) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.title2)
                    }
                } else {
                    Menu {
                        Button(action: onEditStart) {
                            Label("Rename", systemImage: "pencil")
                        }
                        Button(role: .destructive, action: onDelete) {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .frame(width: 30, height: 30)
                            .contentShape(Rectangle())
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            if !isEditing {
                HStack {
                    Image(systemName: "doc.text")
                        .font(.caption)
                    Text("\(module.lessons.count) Lessons")
                        .font(.caption)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(12)
        .padding(.horizontal)
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
}
