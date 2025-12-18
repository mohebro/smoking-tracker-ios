//
//  Habit.swift
//  SmokingTracker
//
//  Created by mohebro on 18.12.2025.
//

import Foundation
import SwiftData

enum HabitMode: String, Codable {
    case positive
    case negative
}

@Model
final class Habit {

    @Attribute(.unique)
    var id: UUID

    var name: String
    var mode: HabitMode

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
