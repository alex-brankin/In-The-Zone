//
//  WorkoutDetailView.swift
//  WatchTheZone Watch App
//
//  Created by Alex Brankin on 19/04/2024.
//
// The WorkoutDetailView in the WatchTheZone app is a detailed interface designed to present
// extensive information about a specific workout from HealthKit data. Displayed in a ScrollView for
// better navigation through content, the view provides metrics such as distance covered, start and
// end times, average and maximum heart rates, and calories burned. It also includes a breakdown of
// the user's performance across different heart rate zones, clearly labeled with respective minimum
// and maximum beats per minute. These zones are highlighted in different colours for easy
// differentiation. Upon appearance, the view fetches detailed workout data through the
// workoutHistoryManager, ensuring all information is up-to-date. This view is pivotal for users
// looking to analyze their workout performance in depth.

import SwiftUI
import HealthKit

enum HeartRateQueryType {
    case average, peak
}

struct WorkoutDetailView: View {
    var workout: HKWorkout
    @ObservedObject var workoutHistoryManager: WorkoutHistoryManager
        
    var body: some View {
        ScrollView{
            VStack(alignment: .leading) {
                Text("Workout Details")
                    .font(.system(size: 20))
                    .foregroundColor(.blue)
                
                Text("Distance: \(workoutHistoryManager.totalDistance)")
                Text("Start : \(workoutHistoryManager.startDate)")
                    .font(.system(size: 14))
                Text("End : \(workoutHistoryManager.endDate)")
                    .font(.system(size: 14))
                Text("Avg Heart Rate : \(workoutHistoryManager.avgHeartRate)")
                    .font(.system(size: 14))
                Text("Max Heart Rate : \(workoutHistoryManager.peakHeartRate)")
                    .font(.system(size: 14))
                Text("Calories: \(workoutHistoryManager.caloriesBurned)")
                    .font(.system(size: 14))
                Spacer()
                
                Text("Target Zone : \(workoutHistoryManager.targetZone)").font(.system(size: 18))
                Text("Zone 1 : \(workoutHistoryManager.zone1Min) - \(workoutHistoryManager.zone1Max) bpm").foregroundColor(.blue).font(.system(size: 14))
                Text("Zone 2 : \(workoutHistoryManager.zone2Min) - \(workoutHistoryManager.zone2Max) bpm").foregroundColor(.green).font(.system(size: 14))
                Text("Zone 3 : \(workoutHistoryManager.zone3Min) - \(workoutHistoryManager.zone3Max) bpm").foregroundColor(.yellow).font(.system(size: 14))
                Text("Zone 4 : \(workoutHistoryManager.zone4Min) - \(workoutHistoryManager.zone4Max) bpm").foregroundColor(.orange).font(.system(size: 14))
                Text("Zone 5 : \(workoutHistoryManager.zone5Min) - \(workoutHistoryManager.zone5Max) bpm").foregroundColor(.red).font(.system(size: 14))
            }
            .padding()
            .onAppear {
                print("Getting Workout Details")
                workoutHistoryManager.getWorkoutDetails(for: workout)
            }
                .navigationBarBackButtonHidden(false)
        }
    }
    struct HistoryView_Previews: PreviewProvider {
        static var previews: some View {
            HistoryView()
        }
    }
    
}
