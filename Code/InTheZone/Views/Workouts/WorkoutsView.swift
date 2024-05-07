//
//  InTheZone
//
//  Created by Alex Brankin on 02/03/2024.
//
// The WorkoutsView in SwiftUI lists workouts retrieved from HealthKit, displaying each as a navigation link to a
// detailed view. It dynamically loads workout data on appearance, showing key metrics like duration and start date
// for activities such as running, walking, cycling, and swimming. Icons and formatted texts enhance the
// presentation, making each workout's information clear and accessible at a glance.

import SwiftUI
import HealthKit
import Charts

struct WorkoutsView: View {
    @State private var myWorkouts: [HKWorkout] = []
    let healthManager = HealthKitManager()
    let workoutAnalyzer = WorkoutAnalyzer()
    

    var body: some View {
        List(myWorkouts, id: \.uuid) { workout in
            NavigationLink(destination: WorkoutDetailView(workoutAnalyzer: workoutAnalyzer, workout: workout)) {
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
            healthManager.retrieveWorkouts { workouts, error in
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

struct WorkoutsView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutsView()
    }
}

