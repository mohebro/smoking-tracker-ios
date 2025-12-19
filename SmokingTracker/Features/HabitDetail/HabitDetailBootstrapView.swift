//
//  HabitDetailBootstrapView.swift
//  SmokingTracker
//
//  Created by mohebro on 19.12.2025.
//

import SwiftUI
import SwiftData

/// A temporary composition root used to bootstrap `HabitDetailView`.
///
/// This view is responsible for:
/// - Accessing the SwiftData `ModelContext` from the environment
/// - Creating the `HabitEntryRepository`
/// - Injecting dependencies into `HabitDetailState`
///
/// This will be removed or replaced once the Dashboard feature is implemented.
struct HabitDetailBootstrapView: View {

    @Environment(\.modelContext)
    private var modelContext

    var body: some View {
        let smokingHabit = Habit(
            name: "Smoking",
            mode: .negative
        )

        let repository = HabitEntryRepository(
            context: modelContext
        )

        HabitDetailView(
            state: HabitDetailState(
                habit: smokingHabit,
                entryRepository: repository
            )
        )
    }
}
