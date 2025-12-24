//
//  HabitDetailViewModel.swift
//  SmokingTracker
//
//  Created by mohebro on 19.12.2025.
//

import Foundation
import Observation

/// ViewModel responsible for the business logic and presentation state
/// of the habit detail screen.
@MainActor
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
    
    /// Indicates whether an async operation is in progress.
    var isLoading: Bool = false
    
    /// User-visible error message, if any.
    var errorMessage: String?
    
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
        isLoading = true
        defer { isLoading = false }
        
        do {
            todayEntry = try await entryRepository.fetchEntry(
                for: habit,
                on: Date()
            )

            currentStreak = streakCalculator.currentStreak(
                entries: habit.entries
            )
        } catch {
            errorMessage = "Failed to load habit data."
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
    func markToday(success: Bool) async {
        guard !isLoading else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await entryRepository.upsertEntry(
                for: habit,
                date: Date(),
                isSuccess: success
            )
            
            await load()
        } catch {
            errorMessage = "Failed to save today’s entry."
        }
    }
}
