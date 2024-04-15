//
//  ChooseExerciseView.swift
//  WatchTheZone Watch App
//
//  Created by Alex Brankin on 14/04/2024.
//

import SwiftUI

struct ChooseExerciseView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: ExerciseViewer(workoutType: .outdoorRun)) {
                    HStack {
                        Image(systemName: "figure.walk")
                            .foregroundColor(.red)
                        Text("Outdoor Run")
                    }
                }
                NavigationLink(destination: ExerciseViewer(workoutType: .indoorRun)) {
                    HStack {
                        Image(systemName: "figure.walk")
                            .foregroundColor(.red)
                        Text("Indoor Run")
                    }
                }
                NavigationLink(destination: ExerciseViewer(workoutType: .outdoorWalking)) {
                    HStack {
                        Image(systemName: "person")
                            .foregroundColor(.red)
                        Text("Outdoor Walking")
                    }
                }
                NavigationLink(destination: ExerciseViewer(workoutType: .indoorWalking)) {
                    HStack {
                        Image(systemName: "person")
                            .foregroundColor(.red)
                        Text("Indoor Walking")
                    }
                }
                NavigationLink(destination: ExerciseViewer(workoutType: .outdoorCycling)) {
                    HStack {
                        Image(systemName: "bicycle")
                            .foregroundColor(.red)
                        Text("Outdoor Cycling")
                    }
                }
                NavigationLink(destination: ExerciseViewer(workoutType: .indoorCycling)) {
                    HStack {
                        Image(systemName: "bicycle")
                            .foregroundColor(.red)
                        Text("Indoor Cycling")
                    }
                }
                NavigationLink(destination: ExerciseViewer(workoutType: .swimming)) {
                    HStack {
                        Image(systemName: "drop")
                            .foregroundColor(.red)
                        Text("Swimming")
                    }
                }
            }
           
        }
    }
}

struct ExerciseViewer: View {
    var workoutType: WorkoutType
    
    var body: some View {
        Text("Start \(workoutType.rawValue)")
    }
}

enum WorkoutType: String {
    case outdoorRun = "Outdoor Run"
    case indoorRun = "Indoor Run"
    case outdoorWalking = "Outdoor Walking"
    case indoorWalking = "Indoor Walking"
    case outdoorCycling = "Outdoor Cycling"
    case indoorCycling = "Indoor Cycling"
    case swimming = "Swimming"
}

struct ChooseExercise_Previews: PreviewProvider {
    static var previews: some View {
        ChooseExerciseView()
    }
}
