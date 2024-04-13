//
//  WorkoutsView.swift
//  InTheZone
//
//  Created by Alex Brankin on 03/04/2024.
//

import SwiftUI

struct Workout: Identifiable {
    var id = UUID()
    var title: String
    var duration: String
    var date: String
    var symbol: String // Add symbol property
}

struct WorkoutsView: View {
    let workouts: [Workout] = [
        Workout(title: "Morning Run", duration: "30 minutes", date: "April 5, 2024", symbol: "figure.run"),
        Workout(title: "Afternoon Walk", duration: "45 minutes", date: "April 4, 2024", symbol: "figure.run"),
        Workout(title: "Evening Bike Ride", duration: "1 hour", date: "April 3, 2024", symbol: "figure.outdoor.cycle"),
        Workout(title: "Evening Bike Ride", duration: "1 hour", date: "April 6, 2024", symbol: "figure.outdoor.cycle"),
    ]
    
    var sortedWorkouts: [Workout] {
        return workouts.sorted { $0.date < $1.date }
    }
    
    var body: some View {
        NavigationView {
            List(sortedWorkouts) { workout in
                NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                    HStack {
                        Image(systemName: workout.symbol)
                            .font(.title)
                        Spacer().frame(width: 12) // Add Spacer with specific width

                        VStack(alignment: .leading, spacing: 4) { // Adjust alignment and spacing
                            Text(workout.title)
                                .font(.headline)
                            Text("Duration: \(workout.duration)")
                                .font(.subheadline)
                            Text("Date: \(workout.date)")
                                .font(.subheadline)
                        }
                    }
                }
            }
            
        }
    }
}

struct WorkoutDetailView: View {
    let workout: Workout
    
    var body: some View {
        VStack {
            Text("Duration: \(workout.duration)")
                .font(.subheadline)
            Text("Date: \(workout.date)")
                .font(.subheadline)
            Spacer()
        }
        .padding()
        .navigationTitle(workout.title)
    }
}

struct WorkoutsView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutsView()
    }
}
