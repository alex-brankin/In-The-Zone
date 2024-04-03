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
}

struct WorkoutsView: View {
    let workouts: [Workout] = [
        Workout(title: "Morning Run", duration: "30 minutes", date: "April 5, 2024"),
        Workout(title: "Afternoon Walk", duration: "45 minutes", date: "April 4, 2024"),
        Workout(title: "Evening Bike Ride", duration: "1 hour", date: "April 3, 2024"),
    ]
    
    var body: some View {
        NavigationView {
            List(workouts) { workout in
                VStack(alignment: .leading) {
                    Text(workout.title)
                        .font(.headline)
                    Text("Duration: \(workout.duration)")
                        .font(.subheadline)
                    Text("Date: \(workout.date)")
                        .font(.subheadline)
                }
            }
            .navigationTitle("Workouts")
        }
    }
}

struct WorkoutsView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutsView()
    }
}

