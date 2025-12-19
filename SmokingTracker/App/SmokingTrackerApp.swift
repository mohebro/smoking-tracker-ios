//
//  SmokingTrackerApp.swift
//  SmokingTracker
//
//  Created by mohebro on 18.12.2025.
//

import SwiftUI
import SwiftData

@main
struct SmokingTrackerApp: App {

    private let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(
                for: Habit.self,
                     HabitEntry.self
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            HabitDetailBootstrapView()
        }
        .modelContainer(modelContainer)
    }
}
