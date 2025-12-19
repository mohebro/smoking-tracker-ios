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
/// - Today's entry status (success / failure / not logged)
///
/// This view also triggers the loading of today's habit entry asynchronously
/// using the `HabitDetailState` object provided during initialization.
struct HabitDetailView: View {

    // MARK: - State

    /// Observable state for this view.
    /// Using `@Bindable` allows SwiftUI to automatically update
    /// the view whenever the state changes.
    @Bindable var state: HabitDetailState

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

            Spacer()
        }
        .padding()
        // Load today's entry asynchronously when view appears
        .task {
            await state.load()
        }
    }

    // MARK: - Subviews

    /// A view that displays today's habit entry status.
    /// - If the entry exists, shows success/failure.
    /// - If no entry exists, indicates "No entry for today".
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
}
