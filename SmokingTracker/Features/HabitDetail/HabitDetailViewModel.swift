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

    /// Indicates whether an async operation (load / save) is in progress.
    var isLoading: Bool = false

    /// User-visible error message, if an operation fails.
    var errorMessage: String?

    /// Indicates whether the screen is currently in editing mode.
    ///
    /// When `false`, the UI is read-only.
    /// When `true`, the user may modify today's result.
    var isEditing: Bool = false

    /// Draft value representing the user's current selection for today.
    ///
    /// This value is bound to the UI (e.g. segmented control),
    /// but is only persisted when the user explicitly submits or finishes editing.
    var draftAction: HabitAction = .success
    
    var showSubmitButton: Bool {
        isEditing || todayEntry == nil
    }

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
    /// - Synchronizes the draft value with persisted data
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

            // Sync draft state with persisted entry (or default for empty state)
            draftAction = if let todayEntry {
                 todayEntry.isSuccess ? .success : .failure
            } else {
                .success
            }

            currentStreak = streakCalculator.currentStreak(
                entries: habit.entries
            )
        } catch {
            errorMessage = "Failed to load habit data."
        }
    }

    // MARK: - Editing Mode

    /// Enters editing mode, allowing the user to modify today's result.
    func beginEditing() {
        isEditing = true
    }

    /// Exits editing mode without persisting changes.
    ///
    /// The draft value is reset to match the persisted entry.
    func cancelEditing() {
        if let todayEntry {
            draftAction = todayEntry.isSuccess ? .success : .failure
        }
        isEditing = false
    }

    // MARK: - User Intents

    /// Persists the current draft value as today's habit entry.
    ///
    /// This method:
    /// - Enforces the one-entry-per-day invariant via upsert
    /// - Persists changes only when explicitly invoked
    /// - Reloads state after completion
    ///
    /// Used both for submitting a new entry and updating an existing one.
    func submitDraft() async {
        guard !isLoading else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await entryRepository.upsertEntry(
                for: habit,
                date: Date(),
                isSuccess: draftAction == .success
            )

            isEditing = false
            await load()
        } catch {
            errorMessage = "Failed to save today’s entry."
        }
    }
}

enum HabitAction {
    case success
    case failure
}
