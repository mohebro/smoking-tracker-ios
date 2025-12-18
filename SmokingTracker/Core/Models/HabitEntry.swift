//
//  HabitEntry.swift
//  SmokingTracker
//
//  Created by mohebro on 18.12.2025.
//

import Foundation
import SwiftData

/// Represents a single daily log for a habit.
///
/// A habit entry records whether the user was successful on a specific
/// calendar day. Optional metadata such as craving level or notes can be
/// attached to provide additional context.
///
/// Design notes:
/// - There should conceptually be only one entry per habit per day.
/// - This constraint is enforced at a higher layer (repository or UI),
///   not at the model level.
/// - The meaning of `isSuccess` depends on the habit type.
@Model
final class HabitEntry {

    /// A unique identifier for the entry.
    @Attribute(.unique)
    var id: UUID

    /// The calendar date this entry represents.
    ///
    /// The time component is not significant and is normalized when
    /// calculating streaks or analytics.
    var date: Date

    /// Indicates whether the user succeeded on this day.
    ///
    /// Interpretation:
    /// - For negative habits (e.g. smoking):
    ///   `true` means the user avoided the habit.
    /// - For positive habits:
    ///   `true` means the user performed the habit.
    ///
    /// Streak calculations operate exclusively on this value.
    var isSuccess: Bool

    /// An optional measure of craving or difficulty for the day.
    ///
    /// This can be used later for analytics or insights, such as identifying
    /// high-risk periods.
    var cravingLevel: Int?

    /// An optional free-form note associated with the entry.
    var note: String?

    /// The habit to which this entry belongs.
    ///
    /// This relationship is required and defines the ownership of the entry.
    @Relationship
    var habit: Habit

    init(
        id: UUID = UUID(),
        date: Date,
        isSuccess: Bool,
        cravingLevel: Int? = nil,
        note: String? = nil,
        habit: Habit
    ) {
        self.id = id
        self.date = date
        self.isSuccess = isSuccess
        self.cravingLevel = cravingLevel
        self.note = note
        self.habit = habit
    }
}
