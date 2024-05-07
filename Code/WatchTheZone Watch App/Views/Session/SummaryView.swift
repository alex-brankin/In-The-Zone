//
//  WatchTheZone
//
//  Created by Alex Brankin on 13/03/2024.
//
// The SummaryView in the WatchTheZone app serves as a comprehensive post-workout summary interface,
// displaying key metrics such as total time, distance, energy burned, and average heart rate from a
// completed workout session. This view utilizes custom SummaryMetricView components for each
// statistic, enhancing readability and visual appeal with color-coded foreground styles. It also
// features a button to dismiss the view, allowing users to easily conclude their review of workout
// details and continue with other activities. The integration of these elements provides a clear
// and concise summary, making it easier for users to assess their performance and health
// improvements directly on their device.

import Foundation
import HealthKit
import SwiftUI
import WatchKit


struct SummaryView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var navigateToStartView = false
    @State private var durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                SummaryMetricView(
                    title: "Target Zone",
                    value: workoutManager.targetZone
                        .formatted(.number.precision(.fractionLength(0)))
                ).foregroundStyle(.yellow)
                
                SummaryMetricView(
                    title: "Total Distance",
                    value: workoutManager.formattedDistance
                ).foregroundStyle(.green)
                
                SummaryMetricView(
                    title: "Total Energy",
                    value: workoutManager.activeEnergy.formatted(.number.precision(.fractionLength(0))) + " Kcal"
                ).foregroundStyle(.cyan)
                
                SummaryMetricView(
                    title: "Avg. Heart Rate",
                    value: workoutManager.averageHeartRate
                        .formatted(.number.precision(.fractionLength(0))) + " BPM"
                ).foregroundStyle(.red)

                
                // Button to trigger navigation
                Button("Done") {
                    workoutManager.endWorkout()
                    workoutManager.resetWorkout()
                    navigateToStartView = true
                }
                
                // Completely non-visible NavigationLink
                NavigationLink("", destination: StartView(), isActive: $navigateToStartView)
                    .hidden() // Ensuring it's truly non-visible
            }
            .scenePadding()
        }
        .navigationTitle("Summary")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
}

struct SummaryMetricView: View {
    var title: String
    var value: String

    var body: some View {
        VStack {
            Text(title)
                .foregroundStyle(.foreground)
            Text(value)
                .font(.system(.title2, design: .rounded).lowercaseSmallCaps())
            Divider()
        }
    }
}
