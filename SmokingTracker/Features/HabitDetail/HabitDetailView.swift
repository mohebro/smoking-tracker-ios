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
    var state: HabitDetailViewModel

    // MARK: - Body

    var body: some View {
        VStack(spacing: 24) {

            // Habit name
            Text(state.habit.name)
                .font(.largeTitle)
                .bold()

            // Current streak
            Text("Current streak: \(state.currentStreak)")
                .font(.title2)

            Divider()

            // Today's status
            todayStatusView

            // User actions
            actionButtons

            Spacer()
        }
        .padding()
        // Trigger asynchronous loading of today's entry
        // when the view appears.
        .task {
            await state.load()
        }
    }

    // MARK: - Subviews

    /// Displays today's habit entry status.
    ///
    /// - If an entry exists, shows whether today was a success or failure.
    /// - If no entry exists, indicates that the habit has not been logged yet.
    @ViewBuilder
    private var todayStatusView: some View {
        if let todayEntry = state.todayEntry {
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
                markToday(success: true)
            }
            .buttonStyle(.borderedProminent)

            Button("Mark as Failure") {
                markToday(success: false)
            }
            .buttonStyle(.bordered)
        }
    }

    // MARK: - User Intents

    /// Marks today's habit result as either success or failure.
    ///
    /// - Parameter success: `true` if the habit was avoided (negative habit),
    ///                      `false` if the habit occurred.
    ///
    /// Errors are currently logged to the console.
    /// This will be replaced with user-facing error handling
    /// once alert presentation is introduced.
    private func markToday(success: Bool) {
        Task {
            do {
                try await state.markToday(success: success)
            } catch {
                // Temporary error handling
                print("Failed to log habit entry:", error)
            }
        }
    }
}
