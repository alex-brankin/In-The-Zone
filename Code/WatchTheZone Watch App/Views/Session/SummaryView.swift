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
    @Environment(\.dismiss) var dismiss
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
                        title: "Total Time",
                        value: durationFormatter
                            .string(from: workoutManager.workout?.duration ?? 0.0) ?? ""
                    ).foregroundStyle(.yellow)
                    
                    SummaryMetricView(
                        title: "Total Distance",
                        value: String(format: "%.2f", (workoutManager.workout?.totalDistance?
                            .doubleValue(for: HKUnit.meter()) ?? 0) / 1000) + "km"
                    ).foregroundStyle(.green)
                    
                    SummaryMetricView(
                        title: "Total Energy",
                        value: Measurement(
                            value: workoutManager.workout?.totalEnergyBurned?
                                            .doubleValue(for: .kilocalorie()) ?? 0,
                            unit: UnitEnergy.kilocalories
                        ).formatted(
                            .measurement(
                                width: .abbreviated,
                                usage: .workout
                            )
                        )
                    ).foregroundStyle(.cyan)
                    SummaryMetricView(
                        title: "Avg. Heart Rate",
                        value: workoutManager.averageHeartRate
                            .formatted(
                                .number.precision(.fractionLength(0))
                            )
                        + " bpm"
                    ).foregroundStyle(.red)
                    Button("Done") {
                        dismiss()
                    }
                    
                }
                .scenePadding()
            }
            .navigationTitle("Summary")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
//}

struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
        let workoutManager = WorkoutManager()
        SummaryView()
            .environmentObject(workoutManager)
    }
}


struct SummaryMetricView: View {
    var title: String
    var value: String

    var body: some View {
        Text(title)
            .foregroundStyle(.foreground)
        Text(value)
            .font(.system(.title2, design: .rounded).lowercaseSmallCaps())
        Divider()
    }
}
