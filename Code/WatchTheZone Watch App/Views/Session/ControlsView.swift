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
    
    var body: some View {
        HStack {
            VStack {
                Button {
                    workoutManager.endWorkout()
                } label: {
                    Image(systemName: "xmark")
                }
                .tint(Color.red)
                .font(.title2)
                Text("End")
            }
            VStack {
                Button {
                    workoutManager.togglePause()
                } label: {
                    Image(systemName: workoutManager.running ? "pause" : "play")
                }
                .tint(Color.yellow)
                .font(.title2)
                Text(workoutManager.running ? "Pause" : "Resume")
            }
        }
    }
}

struct ControlsView_Previews: PreviewProvider {
    static var previews: some View {
        ControlsView().environmentObject(WorkoutManager())
    }
}
