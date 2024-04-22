//
//  WorkoutsView.swift
//  InTheZone
//
//  Created by Alex Brankin on 03/04/2024.
//

import SwiftUI
import HealthKit

struct WorkoutsView: View {
    @StateObject var workoutFinder = WorkoutFinder()
    @State private var myWorkouts: [HKWorkout] = []
    @State private var searchText = ""

    var body: some View {
            List {
                ForEach(filteredWorkouts(), id: \.uuid) { workout in
                    NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                        HStack {
                            Image(systemName: imageForActivity(workout.workoutActivityType))
                                .font(.title)
                            VStack(alignment: .leading) {
                                Text("\(formattedActivity(for: workout))").font(.headline)
                                Text("Duration: \(formattedDuration(for: workout))").font(.subheadline)
                                Text("Date: \(formattedStartDate(for: workout))").font(.subheadline)
                            }
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())
            .searchable(text: $searchText)
            .onAppear {
                // Retrieve workouts when the view appears
                workoutFinder.retrieveWorkouts { workouts, error in
                    if let error = error {
                        // Handle error
                        print("Error retrieving workouts: \(error.localizedDescription)")
                    } else {
                        // Update the state with the retrieved workouts
                        if let workouts = workouts {
                            myWorkouts = workouts
                        }
                    }
                }
            }
        }
    
    
    private func filteredWorkouts() -> [HKWorkout] {
        if searchText.isEmpty {
            return myWorkouts
        } else {
            return myWorkouts.filter { workout in
                let activityString = formattedActivity(for: workout).lowercased()
                return activityString.contains(searchText.lowercased())
            }
        }
    }
    
    private func imageForActivity(_ activityType: HKWorkoutActivityType) -> String {
        switch activityType {
        case .running:
            return "figure.run"
        case .walking:
            return "figure.walk"
        case .cycling:
            return "bicycle"
        case .swimming:
            return "figure.swim"
        @unknown default:
            return "questionmark.circle"
        }
    }
    
    private func formattedDuration(for workout: HKWorkout) -> String {
        let duration = Int(workout.duration)
        let hours = duration / 3600
        let minutes = (duration % 3600) / 60
        let seconds = duration % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    private func formattedStartDate(for workout: HKWorkout) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM, yyyy  HH:mm"
        return dateFormatter.string(from: workout.startDate)
    }
    
    private func formattedActivity(for workout: HKWorkout) -> String {
        let activityType = workout.workoutActivityType
        let activityString: String
        switch activityType {
        case .running:
            activityString = "Running"
        case .walking:
            activityString = "Walking"
        case .cycling:
            activityString = "Cycling"
        case .swimming:
            activityString = "Swimming"
        @unknown default:
            activityString = "Unknown"
        }
        return activityString
    }
}


struct WorkoutDetailView: View {
    let workout: HKWorkout

    var body: some View {
        VStack {
            Text("Workout Details")
                .font(.title)
            Text("Start Date: \(formattedStartDate(for: workout))")
                .font(.subheadline)
            Text("End Date: \(workout.endDate)")
                .font(.subheadline)
            Spacer()
        }
        .padding()
    }
    
    private func formattedStartDate(for workout: HKWorkout) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm, MMMM d, yyyy"
        return dateFormatter.string(from: workout.startDate)
    }
}

struct WorkoutsView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutsView()
    }
}


