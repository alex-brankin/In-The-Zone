//
//  ControlsView.swift
//  WatchTheZone Watch App
//
//  Created by Alex Brankin on 15/04/2024.
//
// The ControlsView in the WatchTheZone Watch App provides intuitive user interface elements for
// managing workout sessions directly from the user's wrist. It features two primary buttons: one to
// end the workout, marked with a red "xmark," and another to toggle between pausing and resuming
// the workout, indicated by a dynamic play/pause icon that reflects the workout's current state.
// This setup allows users to easily control their workout progress with minimal interaction,
// ensuring a seamless exercise experience.

import SwiftUI

struct ControlsView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var navigateToSummaryView = false

    var body: some View {
        ZStack {
            VStack {
                HStack {
                    VStack {
                        Button(action: {
                            navigateToSummaryView = true
                        }) {
                            Image(systemName: "xmark")
                                .font(.title2)
                                .foregroundColor(.red)
                        }
                        Text("End")
                    }

                    VStack {
                        Button(action: {
                            workoutManager.togglePause()
                        }) {
                            Image(systemName: workoutManager.running ? "pause" : "play")
                                .font(.title2)
                                .foregroundColor(workoutManager.running ? .yellow : .green)
                        }
                        Text(workoutManager.running ? "Pause" : "Resume")
                    }
                }
            }

            // Invisible NavigationLink
            NavigationLink(destination: SummaryView(), isActive: $navigateToSummaryView) {
                EmptyView()
            }.buttonStyle(PlainButtonStyle()).frame(width: 0, height: 0).hidden()
        }
    }
}

struct ControlsView_Previews: PreviewProvider {
    static var previews: some View {
        ControlsView().environmentObject(WorkoutManager())
    }
}
