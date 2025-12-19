//
//  HabitDetailState.swift
//  SmokingTracker
//
//  Created by mohebro on 19.12.2025.
//

import Foundation
import Observation

/// Holds the presentation state for `HabitDetailView`.
///
/// This object:
/// - Owns the selected `Habit`
/// - Coordinates data access through `HabitEntryRepository`
/// - Computes derived UI state such as streaks
///
/// It does not manage persistence directly; that responsibility
/// belongs to the repository.
@Observable
final class HabitDetailState {

    // MARK: - Public State

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

    // MARK: - Dependencies

    private let entryRepository: HabitEntryRepository
    private let streakCalculator: StreakCalculator

    // MARK: - Initialization

    /// Creates a new state instance for the habit detail screen.
    ///
    /// - Parameters:
    ///   - habit: The habit to be displayed
    ///   - entryRepository: Repository used to load and persist habit entries
    ///   - streakCalculator: Service responsible for calculating streak values
    init(
        habit: Habit,
        entryRepository: HabitEntryRepository,
        streakCalculator: StreakCalculator = StreakCalculator()
    ) {
        self.habit = habit
        self.entryRepository = entryRepository
        self.streakCalculator = streakCalculator
    }

    // MARK: - Public API

    /// Loads data required for the habit detail screen.
    ///
    /// This method:
    /// - Fetches today's habit entry, if it exists
    /// - Calculates the current streak using the `StreakCalculator`
    ///
    /// Intended to be called from a SwiftUI `.task {}` modifier.
    func load() async {
        do {
            todayEntry = try await entryRepository.fetchEntry(
                for: habit,
                on: Date()
            )

            currentStreak = streakCalculator.currentStreak(entries: habit.entries)
        } catch {
            // For now, failures are logged but not surfaced to the UI.
            // Error handling and user feedback will be added later.
            print("Failed to load habit detail state: \(error)")
        }
    }
}
