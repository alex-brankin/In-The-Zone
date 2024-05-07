//
//  WatchTheZone
//
//  Created by Alex Brankin on 13/03/2024.
//
// The HistoryView in the WatchTheZone app is a SwiftUI view designed to display a list of workouts
// retrieved from HealthKit. Each workout is represented as an item in a List and includes an icon
// indicating the type of workout, such as running or cycling, along with details like the activity
// name, duration, and the date it was performed. Users can tap on any workout to navigate to a
// WorkoutDetailView, which provides more detailed information about the selected workout. The view
// fetches the workouts asynchronously when it appears and updates the list upon successful retrieval
// of data. Error handling is included to manage issues that may arise during data retrieval.

import SwiftUI
import HealthKit

struct HistoryView: View {
    @State private var myWorkouts: [HKWorkout] = []
    //let healthManager = HealthKitManager()
    let workoutHistoryManager = WorkoutHistoryManager()
    

    var body: some View {
        List(myWorkouts, id: \.uuid) { workout in
            NavigationLink(destination: WorkoutDetailView(workout: workout, workoutHistoryManager: workoutHistoryManager)){
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
        .onAppear {
            // Retrieve workouts when the view appears
            workoutHistoryManager.getWorkouts { workouts, error in
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

