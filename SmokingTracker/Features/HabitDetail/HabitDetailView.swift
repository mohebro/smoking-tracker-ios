//
//  HabitDetailView.swift
//  SmokingTracker
//
//  Created by mohebro on 19.12.2025.
//

import SwiftUI

struct HabitDetailView: View {

    @State private var state: HabitDetailState

    init(state: HabitDetailState) {
        _state = State(initialValue: state)
    }

    var body: some View {
        VStack(spacing: 24) {

            Text(state.habit.name)
                .font(.largeTitle)
                .bold()

            Text("Current streak: \(state.currentStreak)")
                .font(.title2)

            Divider()

            if let todayEntry = state.todayEntry {
                Text(todayEntry.isSuccess ? "Today: Success" : "Today: Failure")
                    .font(.headline)
            } else {
                Text("No entry for today")
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .task {
            await state.load()
        }
    }
}
