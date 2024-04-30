//
//  WatchTheZone
//
//  Created by Alex Brankin on 13/03/2024.
//

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
                    Text("Activity Rings")
                    ActivityRingsView(healthStore: workoutManager.healthStore)
                        .frame(width: 50, height: 50)
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
