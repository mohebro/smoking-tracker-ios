//
//  HabitRepository.swift
//  SmokingTracker
//
//  Created by mohebro on 20.12.2025.
//

import Foundation
import SwiftData

/// Repository responsible for managing `Habit` persistence.
///
/// This type encapsulates all SwiftData interactions related
/// to `Habit` entities, shielding higher layers from persistence
/// implementation details.
///
/// The repository is annotated with `@MainActor` because
/// SwiftData's `ModelContext` must be accessed on the main thread.
@MainActor
final class HabitRepository {

    // MARK: - Properties

    /// The SwiftData model context used for fetching and persisting habits.
    private let context: ModelContext

    // MARK: - Initialization

    /// Creates a new `HabitRepository`.
    ///
    /// - Parameter context: The `ModelContext` used for persistence operations.
    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - Public API

    /// Fetches the persisted `Smoking` habit if it exists,
    /// or creates and persists it if it does not.
    ///
    /// This method is idempotent and safe to call multiple times.
    /// It guarantees that only a single `Smoking` habit exists.
    ///
    /// - Returns: A persisted `Habit` instance representing smoking.
    /// - Throws: An error if fetching or saving fails.
    func getOrCreateSmokingHabit() async throws -> Habit {
        let descriptor = FetchDescriptor<Habit>(
            predicate: #Predicate { $0.name == "Smoking" }
        )

        if let existing = try context.fetch(descriptor).first {
            return existing
        }

        let habit = Habit(name: "Smoking", mode: .negative)
        context.insert(habit)
        try context.save()
        return habit
    }
}
