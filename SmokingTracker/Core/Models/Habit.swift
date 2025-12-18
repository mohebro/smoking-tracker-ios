//
//  Habit.swift
//  SmokingTracker
//
//  Created by mohebro on 18.12.2025.
//

import Foundation
import SwiftData

/// Represents a habit that the user wants to track over time.
///
/// A habit can be either positive (something the user wants to do more of)
/// or negative (something the user wants to reduce or avoid).
///
/// Each habit owns a collection of daily entries that record whether the
/// user was successful on a given day.
///
/// Design notes:
/// - This model is persistence-focused and contains no business logic.
/// - Streaks and analytics are intentionally calculated outside the model.
/// - Deleting a habit cascades and deletes all associated entries.
@Model
final class Habit {

    /// A unique identifier for the habit.
    ///
    /// Explicitly defining the identifier improves clarity and makes the
    /// model easier to reason about when syncing or migrating in the future.
    @Attribute(.unique)
    var id: UUID

    /// A human-readable name for the habit.
    ///
    /// Examples:
    /// - "Smoking"
    /// - "Exercise"
    /// - "Reading"
    var name: String

    /// Defines whether the habit is positive or negative.
    ///
    /// The habit mode determines how a successful entry should be interpreted,
    /// but does not affect persistence or streak calculation directly.
    var mode: HabitMode

    /// The collection of daily entries associated with this habit.
    ///
    /// Each entry represents the outcome for a single calendar day.
    /// Entries are deleted automatically when the habit is removed.
    @Relationship(deleteRule: .cascade)
    var entries: [HabitEntry]

    init(
        id: UUID = UUID(),
        name: String,
        mode: HabitMode,
        entries: [HabitEntry] = []
    ) {
        self.id = id
        self.name = name
        self.mode = mode
        self.entries = entries
    }
}

/// Describes whether a habit is positive or negative.
///
/// - positive: The user wants to perform the habit more frequently.
/// - negative: The user wants to reduce or eliminate the habit.
enum HabitMode: String, Codable {
    case positive
    case negative
}
