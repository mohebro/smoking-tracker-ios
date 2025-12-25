//
//  HabitDetailView.swift
//  SmokingTracker
//
//  Created by mohebro on 19.12.2025.
//

import SwiftUI

/// Displays the details of a single habit, including:
/// - Habit name
/// - Current streak
/// - Today's logging status
/// - Editing controls for success / failure
///
/// This view is intentionally lightweight:
/// - All business logic lives in `HabitDetailViewModel`
/// - The view reacts purely to observable state changes
///
/// The view supports:
/// - Viewing today's logged result
/// - Entering an edit mode to modify today's entry
/// - Creating a new entry when none exists
struct HabitDetailView: View {
    
    // MARK: - State
    
    /// Observable ViewModel driving the screen.
    ///
    /// This ViewModel owns all business logic, async work,
    /// and state transitions for the habit detail flow.
    @Bindable var viewModel: HabitDetailViewModel
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 24) {
            
            streakSection(streak: viewModel.currentStreak)
            
            Divider()
            
            // Today's status section (view or edit)
            todaySection(
                todayEntry: viewModel.todayEntry,
                isEditing: viewModel.isEditing,
                draftAction: $viewModel.draftAction
            )
            
            // Submit button appears only when required
            if viewModel.showSubmitButton {
                submitButton(isLoading: viewModel.isLoading)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle(viewModel.habit.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            toolbarContent(
                todayEntry: viewModel.todayEntry,
                isEditing: viewModel.isEditing
            )
        }
        .alert(
            "Error",
            isPresented: .constant(viewModel.errorMessage != nil),
            actions: {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            },
            message: {
                Text(viewModel.errorMessage ?? "")
            }
        )
        // Triggers asynchronous loading of today's entry
        // when the view first appears.
        .task {
            await viewModel.load()
        }
    }
    
    // MARK: - Sections
    
    /// Primary action button used to submit a new entry
    /// or upsert an edited entry.
    ///
    /// - Parameter isLoading: Indicates whether a submission
    ///   is currently in progress.
    private func submitButton(isLoading: Bool) -> some View {
        Button("Submit")  {
            Task {
                await viewModel.submitDraft()
            }
        }
        .buttonStyle(.borderedProminent)
        .disabled(isLoading)
        .overlay {
            if isLoading {
                ProgressView()
                    .scaleEffect(1.5)
            }
        }
    }
    
    /// Displays the user's current streak for this habit.
    ///
    /// - Parameter streak: Number of consecutive successful days.
    private func streakSection(streak: Int) -> some View {
        Text("Current streak: \(streak)")
            .font(.title2)
    }
    
    /// Displays today's habit entry state.
    ///
    /// Behavior:
    /// - If an entry exists and the user is not editing,
    ///   the result is shown as read-only text.
    /// - If editing or no entry exists,
    ///   a segmented picker is shown to select success or failure.
    ///
    /// - Parameters:
    ///   - todayEntry: Optional entry for today.
    ///   - isEditing: Whether the view is currently in edit mode.
    ///   - draftAction: Binding to the draft action state.
    private func todaySection(
        todayEntry: HabitEntry?,
        isEditing: Bool,
        draftAction: Binding<HabitAction>
    ) -> some View {
        VStack(spacing: 16) {
            if let entry = todayEntry, !isEditing {
                Text(entry.isSuccess ? "Today: Success" : "Today: Failure")
                    .font(.headline)
            } else {
                Picker("Today", selection: draftAction) {
                    Text("Success").tag(HabitAction.success)
                    Text("Failure").tag(HabitAction.failure)
                }
                .pickerStyle(.segmented)
            }
        }
    }
    
    // MARK: - Toolbar
    
    /// Navigation bar toolbar content.
    ///
    /// Displays an Edit / Cancel button when
    /// a habit entry already exists for today.
    ///
    /// - Parameters:
    ///   - todayEntry: Optional entry for today.
    ///   - isEditing: Whether the view is currently in edit mode.
    @ToolbarContentBuilder
    private func toolbarContent(
        todayEntry: HabitEntry?,
        isEditing: Bool
    ) -> some ToolbarContent {
        if todayEntry != nil {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "Cancel" : "Edit") {
                    Task {
                        await if isEditing {
                            viewModel.cancelEditing()
                        } else {
                            viewModel.beginEditing()
                        }
                    }
                }
            }
        }
    }
}
