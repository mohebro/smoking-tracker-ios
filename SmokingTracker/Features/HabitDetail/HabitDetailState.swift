//
//  HabitDetailState.swift
//  SmokingTracker
//
//  Created by mohebro on 19.12.2025.
//

import Foundation
import Observation

/// UI state for the Habit Detail screen.
///
/// `HabitDetailState` owns all state required to render and interact
/// with the daily habit check-in screen. It is observed by SwiftUI
/// views using the `@Observable` macro.
///
/// Responsibilities:
/// - Hold the selected habit
/// - Store today's habit entry, if it exists
/// - Expose the current streak value for display
///
/// This type intentionally contains no persistence logic.
/// Data loading and mutations are performed via repositories
/// and reflected back into this state.
@Observable
final class HabitDetailState {

    /// The habit being displayed and tracked.
    let habit: Habit

    /// The habit entry for today, if the user has already logged one.
    var todayEntry: HabitEntry?

    /// The current consecutive-day streak for this habit.
    ///
    /// For negative habits (e.g. smoking), the streak represents
    /// the number of consecutive days the user successfully avoided
    /// the habit.
    var currentStreak: Int = 0

    /// Creates a new state instance for the given habit.
    ///
    /// - Parameter habit: The habit to be displayed on the detail screen.
    init(habit: Habit) {
        self.habit = habit
    }
}
