//
//  HabitDetailView.swift
//  SmokingTracker
//
//  Created by mohebro on 19.12.2025.
//

import SwiftUI

/// Displays the details of a single habit.
///
/// This view is responsible for presenting:
/// - The habit name
/// - The current streak length
/// - Today's habit entry status (success / failure / not logged)
/// - User actions to mark today's habit outcome
///
/// The view itself contains no business logic.
/// All state mutations and data loading are delegated to
/// the injected `HabitDetailState`, following MVVM principles.
struct HabitDetailView: View {

    // MARK: - State

    /// Bindable observable state for this view.
    ///
    /// Using `@Bindable` allows SwiftUI to automatically
    /// update the UI whenever properties of `HabitDetailState`
    /// change, without manual state propagation.
    @Bindable
    var viewModel: HabitDetailViewModel

    // MARK: - Body

    var body: some View {
        VStack(spacing: 24) {

            // Habit name
            Text(viewModel.habit.name)
                .font(.largeTitle)
                .bold()

            // Current streak
            Text("Current streak: \(viewModel.currentStreak)")
                .font(.title2)

            Divider()

            // Today's status
            todayStatusView

            // User actions
            actionButtons
                .disabled(viewModel.isLoading)
            
                .overlay {
                    if viewModel.isLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                    }
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

            Spacer()
        }
        .padding()
        // Trigger asynchronous loading of today's entry
        // when the view appears.
        .task {
            await viewModel.load()
        }
    }

    // MARK: - Subviews

    /// Displays today's habit entry status.
    ///
    /// - If an entry exists, shows whether today was a success or failure.
    /// - If no entry exists, indicates that the habit has not been logged yet.
    @MainActor
    @ViewBuilder
    private var todayStatusView: some View {
        if let todayEntry = viewModel.todayEntry {
            Text(todayEntry.isSuccess ? "Today: Success" : "Today: Failure")
                .font(.headline)
        } else {
            Text("No entry for today")
                .foregroundColor(.secondary)
        }
    }

    /// Action buttons allowing the user to mark today's habit result.
    ///
    /// These buttons translate user intent into calls on `HabitDetailState`.
    /// Any persistence or validation errors are handled asynchronously.
    private var actionButtons: some View {
        VStack(spacing: 12) {

            Button("Mark as Success") {
                Task { await viewModel.markToday(success: true) }
            }
            .buttonStyle(.borderedProminent)

            Button("Mark as Failure") {
                Task { await viewModel.markToday(success: false) }
            }
            .buttonStyle(.bordered)
        }
    }
}
