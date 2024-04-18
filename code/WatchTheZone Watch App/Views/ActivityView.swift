//
//  ActivityView.swift
//  WatchTheZone Watch App
//
//  Created by Alex Brankin on 16/04/2024.
//

import SwiftUI
import HealthKit

struct ActivityView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
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
            workoutManager.requestAuthorization()
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
