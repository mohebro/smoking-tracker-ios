//
//  HabitDetailBootstrapView.swift
//  SmokingTracker
//
//  Created by mohebro on 19.12.2025.
//

import SwiftUI
import SwiftData

/// A temporary composition root responsible for bootstrapping `HabitDetailView`.
///
/// This view owns the responsibility of:
/// - Accessing the SwiftData `ModelContext` from the environment
/// - Bootstrapping the default `Smoking` habit via `HabitRepository`
/// - Constructing persistence-layer dependencies
/// - Injecting all required dependencies into `HabitDetailState`
///
/// This view intentionally contains *composition logic only*
/// and no business logic. It will be removed or replaced once
/// a proper Dashboard or navigation flow is implemented.
struct HabitDetailBootstrapView: View {

    /// The SwiftData model context provided by the app container.
    /// Used exclusively for repository construction.
    @Environment(\.modelContext)
    private var modelContext

    /// The persisted `Habit` instance to be displayed.
    ///
    /// This is loaded asynchronously during view startup.
    /// The view renders a loading state until this value is set.
    @State
    private var habit: Habit?

    var body: some View {
        NavigationStack {
            Group {
                if let habit {
                    // Dependency construction is intentionally kept here,
                    // making this view the composition root.
                    let entryRepository = HabitEntryRepository(
                        context: modelContext
                    )
                    
                    HabitDetailView(
                        viewModel: HabitDetailViewModel(
                            habit: habit,
                            entryRepository: entryRepository
                        )
                    )
                } else {
                    ProgressView()
                        .progressViewStyle(
                            CircularProgressViewStyle(tint: .blue)
                        )
                        .scaleEffect(2.0)
                }
            }
            .task {
                await bootstrapHabitIfNeeded()
            }
        }
    }

    // MARK: - Bootstrap Logic

    /// Loads or creates the default `Smoking` habit.
    ///
    /// This method is intentionally placed here to keep
    /// initialization concerns out of views and state objects.
    ///
    /// - Note: Errors are considered unrecoverable at this stage
    ///         of the application and will cause a crash.
    ///         This will be revisited once error handling and
    ///         user-facing recovery flows are introduced.
    @MainActor
    private func bootstrapHabitIfNeeded() async {
        do {
            let repository = HabitRepository(context: modelContext)
            habit = try await repository.getOrCreateSmokingHabit()
        } catch {
            fatalError("Failed to bootstrap default Smoking habit: \(error)")
        }
    }
}
