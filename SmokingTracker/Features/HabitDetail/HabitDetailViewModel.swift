//
//  HabitDetailViewModel.swift
//  SmokingTracker
//
//  Created by mohebro on 19.12.2025.
//

import Foundation
import Observation

/// View model responsible for driving `HabitDetailView`.
///
/// `HabitDetailViewModel`:
/// - Owns the selected `Habit`
/// - Coordinates data access via `HabitEntryRepository`
/// - Computes derived presentation state such as streaks
///
/// This type contains **presentation logic only**.
/// Persistence concerns are delegated to repositories, keeping
/// responsibilities well-separated and testable.
@Observable
final class HabitDetailViewModel {

    // MARK: - Public State

    /// The habit being displayed and tracked.
    ///
    /// This value is immutable for the lifetime of the view model.
    let habit: Habit

    /// The habit entry for today, if the user has already logged one.
    ///
    /// `nil` indicates that the habit has not yet been logged today.
    var todayEntry: HabitEntry?

    /// The current consecutive-day streak for this habit.
    ///
    /// For negative habits (e.g. smoking), the streak represents
    /// the number of consecutive days the user successfully avoided
    /// the habit.
    var currentStreak: Int = 0

    // MARK: - Dependencies

    /// Repository responsible for fetching and persisting habit entries.
    private let entryRepository: HabitEntryRepository

    /// Service responsible for calculating streak values
    /// based on historical habit entries.
    private let streakCalculator: StreakCalculator

    // MARK: - Initialization

    /// Creates a new view model for the habit detail screen.
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

    // MARK: - Lifecycle

    /// Loads data required for the habit detail screen.
    ///
    /// This method:
    /// - Fetches today's habit entry, if it exists
    /// - Computes the current streak using historical entries
    ///
    /// Intended to be called from a SwiftUI `.task {}` modifier.
    /// Runs on the main actor to safely update observable state.
    func load() async {
        do {
            todayEntry = try await entryRepository.fetchEntry(
                for: habit,
                on: Date()
            )

            currentStreak = streakCalculator.currentStreak(
                entries: habit.entries
            )
        } catch {
            // Temporary error handling.
            // Failures are logged but not surfaced to the UI yet.
            // This will be replaced with user-facing error handling later.
            print("Failed to load habit detail view model:", error)
        }
    }

    // MARK: - User Intents

    /// Logs today's habit result as success or failure.
    ///
    /// - Parameter success: `true` if the habit was avoided (negative habit),
    ///                      `false` if the habit occurred.
    ///
    /// After persisting the entry, the view model reloads its state
    /// to keep derived values (e.g. streak) consistent.
    func markToday(success: Bool) async throws {
        try await entryRepository.upsertEntry(
            for: habit,
            date: Date(),
            isSuccess: success
        )

        await load()
    }
}
