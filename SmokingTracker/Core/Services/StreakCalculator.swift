//
//  StreakCalculator.swift
//  SmokingTracker
//
//  Created by mohebro on 18.12.2025.
//

import Foundation

/// A stateless utility responsible for calculating habit streaks.
///
/// `StreakCalculator` operates purely on in-memory data and has no
/// dependency on persistence, UI, or SwiftData APIs. This makes the logic
/// deterministic, testable, and reusable.
///
/// A streak is defined as a sequence of consecutive calendar days where
/// the habit entry was successful (`isSuccess == true`).
///
/// Important design notes:
/// - The calculator is habit-agnostic.
/// - The meaning of "success" is determined at entry creation time,
///   not during calculation.
/// - Missing days are treated as streak-breaking.
struct StreakCalculator {

    /// Calculates the current streak up to today.
    ///
    /// The current streak represents the number of consecutive days,
    /// ending today, for which the habit was successfully completed.
    ///
    /// Rules:
    /// - Only entries marked as successful are considered.
    /// - Multiple entries on the same day are normalized into one.
    /// - If there is no successful entry for today, the streak is zero.
    ///
    /// - Parameter entries: A collection of habit entries.
    /// - Returns: The number of consecutive successful days up to today.
    func currentStreak(entries: [HabitEntry]) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let successfulDays = normalizedSuccessfulDays(entries: entries)

        // If today was not successful, there is no active streak.
        guard successfulDays.contains(today) else {
            return 0
        }

        var streak = 0
        var currentDate = today

        while successfulDays.contains(currentDate) {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else {
                break
            }
            currentDate = previousDay
        }

        return streak
    }

    /// Calculates the longest streak across all recorded entries.
    ///
    /// The longest streak represents the maximum number of consecutive
    /// successful days at any point in time.
    ///
    /// - Parameter entries: A collection of habit entries.
    /// - Returns: The longest sequence of consecutive successful days.
    func longestStreak(entries: [HabitEntry]) -> Int {
        let calendar = Calendar.current
        let successfulDays = normalizedSuccessfulDays(entries: entries)
            .sorted()

        var longest = 0
        var current = 0
        var previousDate: Date?

        for date in successfulDays {
            if let prev = previousDate,
               calendar.date(byAdding: .day, value: 1, to: prev) == date {
                current += 1
            } else {
                current = 1
            }
            longest = max(longest, current)
            previousDate = date
        }

        return longest
    }
}

private extension StreakCalculator {

    /// Normalizes successful habit entries into unique calendar days.
    ///
    /// This helper ensures:
    /// - Only successful entries are considered.
    /// - Multiple entries on the same day collapse into one.
    /// - Time components are removed by normalizing to start-of-day.
    ///
    /// - Parameter entries: A collection of habit entries.
    /// - Returns: A set of unique calendar days with successful entries.
    func normalizedSuccessfulDays(entries: [HabitEntry]) -> Set<Date> {
        let calendar = Calendar.current

        return Set(
            entries
                .filter { $0.isSuccess }
                .map { calendar.startOfDay(for: $0.date) }
        )
    }
}
