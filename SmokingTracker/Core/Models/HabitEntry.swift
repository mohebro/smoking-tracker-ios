//
//  HabitEntry.swift
//  SmokingTracker
//
//  Created by mohebro on 18.12.2025.
//

import Foundation
import SwiftData

@Model
final class HabitEntry {

    @Attribute(.unique)
    var id: UUID

    var date: Date

    var isSuccess: Bool

    var cravingLevel: Int?
    var note: String?

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
