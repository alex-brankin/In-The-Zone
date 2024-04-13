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
        List(previousWorkouts, id: \.id) { workout in
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
            HStack {
                Text("Total Time: \(formattedTime(workout.totalTime))")
                Spacer()
                Text("Avg HR: \(workout.averageHeartRate) bpm")
                Spacer()
                Text("Max HR: \(workout.maxHeartRate) bpm")
            }
            .foregroundColor(.blue)
            .padding(.bottom, 5)
            }
            HStack {
                Text("Distance: \(workout.distance) km")
                Spacer()
                Text("Calories: \(workout.caloriesBurned) kcal")
            }
            .foregroundColor(.green)
        }
    }
    
    private func formattedTime(_ time: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: time) ?? ""
    }


struct HeartRateDataRow: View {
    var zone: String
    var time: TimeInterval
    
    var body: some View {
        HStack {
            Text("Zone \(zone):")
            Spacer()
            Text("\(formattedTime(time))")
        }
    }
    
    private func formattedTime(_ time: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: time) ?? ""
    }
}

struct WorkoutDetailView: View {
    var workout: Workout
    
    var body: some View {
        VStack {
            Text("Details for \(workout.title)")
                .font(.headline)
                .padding()
            HStack {
                Text("Total Time: \(formattedTime(workout.totalTime))")
                Spacer()
                Text("Avg HR: \(workout.averageHeartRate) bpm")
                Spacer()
                Text("Max HR: \(workout.maxHeartRate) bpm")
            }
            .foregroundColor(.blue)
            .padding(.bottom, 5)
            ForEach(workout.zoneTimes.keys.sorted(), id: \.self) { zone in
                HeartRateDataRow(zone: zone, time: workout.zoneTimes[zone] ?? 0)
            }
            HStack {
                Text("Distance: \(workout.distance) km")
                Spacer()
                Text("Calories: \(workout.caloriesBurned) kcal")
            }
            .foregroundColor(.green)
        }
        .padding()
    }
    
    private func formattedTime(_ time: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: time) ?? ""
    }
}

struct PreviousWorkoutsView_Previews: PreviewProvider {
    static var previews: some View {
        PreviousWorkoutsView(previousWorkouts: previousWorkouts)
    }
}
