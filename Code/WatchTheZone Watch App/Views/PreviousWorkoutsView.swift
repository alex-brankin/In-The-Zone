//
//  PreviousWorkoutsView.swift
//  WatchTheZone Watch App
//
//  Created by Alex Brankin on 09/04/2024.
//

import SwiftUI

struct PreviousWorkoutsView: View {
    var previousWorkouts: [Workout] // Pass in previous workouts
    @State private var selectedWorkout: Workout?
    
    var body: some View {
        List(previousWorkouts, id: \.title) { workout in
            Button(action: {
                self.selectedWorkout = workout
            }) {
                WorkoutRow(workout: workout)
            }
        }
        .navigationTitle("Previous Workouts")
        .sheet(item: $selectedWorkout) { workout in
            WorkoutDetailView(workout: workout)
        }
    }
}

struct WorkoutRow: View {
    var workout: Workout
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(workout.title)
                .font(.headline)
                .padding(.bottom, 5)
            ForEach(workout.heartRateData, id: \.time) { data in
                HeartRateDataRow(data: data)
            }
        }
        .padding()
    }
}

struct HeartRateDataRow: View {
    var data: HeartRateData
    
    var body: some View {
        HStack {
            Text("\(data.time): ")
            Text("\(data.heartRate) bpm")
                .foregroundColor(.blue)
            Text(" - \(data.zone)")
                .foregroundColor(.green)
        }
    }
}

struct WorkoutDetailView: View {
    var workout: Workout
    
    var body: some View {
        VStack {
            Text("Details for \(workout.title)")
                .font(.headline)
                .padding()
            ForEach(workout.heartRateData, id: \.time) { data in
                HeartRateDataRow(data: data)
            }
             
            }
        }
    }


struct PreviousWorkoutsView_Previews: PreviewProvider {
    static var previews: some View {
        PreviousWorkoutsView(previousWorkouts: previousWorkouts)
    }
}

