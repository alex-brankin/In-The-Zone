//
//  ActivityView.swift
//  WatchTheZone Watch App
//
//  Created by Alex Brankin on 16/04/2024.
//
// The ActivityView in the WatchTheZone app provides users with a selection interface for different
// types of workouts like cycling, running, and walking, each linked to a specific workout intensity
// zone. Users can choose their workout type via navigation links, which direct them to a
// SessionPagingView tailored to their chosen activity and target zone. This view dynamically
// updates the WorkoutManager's selectedWorkout property to reflect the user's selection, ensuring
// that workout sessions are correctly initialized with the chosen settings. The view is styled in a
// carousel list format, offering a visually appealing and easy-to-navigate interface. Additionally, 
// the view is configured to update the targetZone in the WorkoutManager upon appearance, preparing
// the app for a new workout session.

import SwiftUI
import HealthKit

struct ActivityView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var workoutUIManager: WorkoutUIManager
    var targetZone: Int
    var workoutTypes: [HKWorkoutActivityType] = [.cycling, .running, .walking]
    var body: some View {
        List(workoutTypes) { workoutType in
            NavigationLink(
                workoutType.name,
                destination: SessionPagingView(targetZone: targetZone),
                tag: workoutType,
                selection: $workoutManager.selectedWorkout
            ).padding(EdgeInsets(top: 15, leading: 5, bottom: 15, trailing:5 )
            )
        }
        .listStyle(.carousel)
        // .navigationBarTitle("Workouts")
        .onAppear {
            //workoutManager.requestAuthorization()
            workoutManager.targetZone = targetZone
        }
    }
}

#Preview {
    ActivityView(targetZone:3).environmentObject(WorkoutManager())
}

extension HKWorkoutActivityType: Identifiable {
    public var id: UInt {
        rawValue
    }
    
    var name: String{
        switch self {
        case .running:
            return "Run"
        case .cycling:
            return "Bike"
        case .walking:
            return "Walk"
        default:
            return ""
        }
    }
}
