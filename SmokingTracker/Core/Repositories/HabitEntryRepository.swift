//
//  HabitEntryRepository.swift
//  SmokingTracker
//
//  Created by mohebro on 19.12.2025.
//

import Foundation
import SwiftData

/// Repository responsible for managing `HabitEntry` persistence.
///
/// - Encapsulates SwiftData interactions
/// - Enforces one-entry-per-day invariant
/// - Exposes async APIs for future persistence replacement
final class HabitEntryRepository {

    // MARK: - Dependencies

    @MainActor
    private let context: ModelContext
    private let calendar: Calendar

    // MARK: - Initialization

    init(
        context: ModelContext,
        calendar: Calendar = .current
    ) {
        self.context = context
        self.calendar = calendar
    }

    // MARK: - Public API

    /// Creates or updates a habit entry for a given day.
    ///
    /// Business rules:
    /// - Only one entry is allowed per habit per day
    /// - If an entry already exists for the given date, it is updated
    /// - Otherwise, a new entry is created and attached to the habit
    ///
    /// - Parameters:
    ///   - habit: The habit the entry belongs to
    ///   - date: The date of the entry
    ///   - isSuccess: Indicates whether the habit was avoided successfully
    ///   - cravingLevel: Optional craving intensity (e.g., 1–5)
    ///   - note: Optional user note
    func upsertEntry(
        for habit: Habit,
        date: Date,
        isSuccess: Bool,
        cravingLevel: Int? = nil,
        note: String? = nil
    ) async throws {

        try await MainActor.run {
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

            if let existingEntry = habit.entries.first(where: {
                $0.date >= startOfDay && $0.date < endOfDay
            }) {
                existingEntry.isSuccess = isSuccess
                existingEntry.cravingLevel = cravingLevel
                existingEntry.note = note
            } else {
                let entry = HabitEntry(
                    date: date,
                    isSuccess: isSuccess,
                    cravingLevel: cravingLevel,
                    note: note,
                    habit: habit
                )
                habit.entries.append(entry)
            }

            try context.save()
        }
    }

    /// Fetches all entries for a habit, optionally filtered by date range.
    ///
    /// - Parameters:
    ///   - habit: The habit whose entries should be fetched
    ///   - from: Optional start date (inclusive)
    ///   - to: Optional end date (inclusive)
    ///
    /// - Returns: An array of `HabitEntry` sorted by date ascending
    func fetchEntries(
        for habit: Habit,
        from startDate: Date? = nil,
        to endDate: Date? = nil
    ) async throws -> [HabitEntry] {

        await MainActor.run {
            var entries = habit.entries

            if let startDate {
                entries = entries.filter { $0.date >= startDate }
            }

            if let endDate {
                entries = entries.filter { $0.date <= endDate }
            }

            return entries.sorted { $0.date < $1.date }
        }
    }

    /// Fetches a single habit entry for a specific day, if it exists.
    ///
    /// - Parameters:
    ///   - habit: The habit whose entry should be fetched
    ///   - date: The target date
    ///
    /// - Returns: The entry for that day, or `nil` if none exists
    func fetchEntry(
        for habit: Habit,
        on date: Date
    ) async throws -> HabitEntry? {
        
        await MainActor.run {
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

            return habit.entries.first {
                $0.date >= startOfDay && $0.date < endOfDay
            }
        }
    }
}
