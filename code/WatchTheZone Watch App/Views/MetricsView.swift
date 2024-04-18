//
//  MetricsView.swift
//  WatchTheZone Watch App
//
//  Created by Alex Brankin on 16/04/2024.
//

import SwiftUI
import HealthKit

struct MetricsView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var averagePace: String = "Not Moving"
    var targetZone: Int
    @AppStorage("hapticFeedbackEnabled") var hapticFeedbackEnabled: Bool = false
    @AppStorage("hapticFrequencyMinutes") var hapticFrequencyMinutes: Double = 10
    @AppStorage("hapticDelayMinutes") var hapticDelayMinutes: Double = 10
    @AppStorage("distanceUnit") var distanceUnit: String = DistanceUnit.kilometers.rawValue
    @State private var showingSummaryView = false
    
    private var onTarget: Bool {
        targetZone == currentZone(for: workoutManager.heartRate)
    }

    
    @State private var lastHapticFeedbackTime = Date()


    let z1min = 0, z1max = 55, z2min = 56, z2max = 65, z3min = 66, z3max = 75, z4min = 76, z4max = 85, z5min = 86, z5max = 200
    
    var body: some View {
        TimelineView(MetricsTimelineSchedule(
            from: workoutManager.builder?.startDate ?? Date()
        )) { context in
            VStack(alignment: .leading) {
                ElapsedTimeView(elapsedTime: workoutManager.builder?.elapsedTime(at: context.date) ?? 0, showSubseconds: context.cadence == .live)
                    .foregroundStyle(.yellow)
                    .padding(.top, 20)
                
                // Heart Rate Text with flashing color
                VStack(alignment: .leading){
                    HStack{
                        Text(workoutManager.heartRate.formatted(.number.precision(.fractionLength(0))) + " bpm ")
                            .foregroundColor(bpmColor(for: workoutManager.heartRate, position: "Foreground", targetSensitive: false))
                            .background(bpmColor(for: workoutManager.heartRate, position: "Background", targetSensitive: false))
                        Text(" ")
                            .foregroundColor(bpmColor(for: workoutManager.heartRate, position: "Foreground", targetSensitive: false))
                            .font(.subheadline)
                        Image(systemName: speedIndicator()).foregroundColor(bpmColor(for: workoutManager.heartRate, position: "Foreground", targetSensitive: false))
                            .font(.system(size: 30))
                    }
                    .padding(.bottom, -6)
                    ZStack {
                        Rectangle()
                            .foregroundColor(bpmColor(for: workoutManager.heartRate, position: "Foreground", targetSensitive: false)) // Adjust color and opacity as needed
                            .frame(height: 20)
                            .cornerRadius(8) // Optional: Add corner radius for rounded corners
                        
                        Text("Zone " + String(currentZone(for: workoutManager.heartRate)))
                            .foregroundColor(.white) // Adjust text color as needed
                            .font(.system(size: 14))
                      
                    }
                 
                }
                Text(averagePace).font(.system(size: 25)).padding(.top, -4)
                
                if String(distanceUnit) == "miles"
                {
                        Text(String(format: "%.2f miles", ((workoutManager.distance / 1000) * 0.621371 ))).font(.system(size: 25))
                }
                if String(distanceUnit) == "kilometers"
                {
                    if workoutManager.distance < 50 {
                        Text(String(format: "%.0f metres", workoutManager.distance.rounded())).font(.system(size: 25))
                    } else {
                        Text(String(format: "%.2f kilometres", (workoutManager.distance / 1000))).font(.system(size: 25))
                    }
                }
            }
            .font(.system(.title, design: .rounded).monospacedDigit().lowercaseSmallCaps())
            .frame(maxWidth: .infinity, alignment: .leading)
            .ignoresSafeArea(edges: .bottom)
            .scenePadding()
            .onAppear {
                // Start a timer to recalculate average pace every 5 seconds
                Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                    averagePace = calculateAveragePace()
                }
                
                
                    Timer.scheduledTimer(withTimeInterval: (hapticFrequencyMinutes * 60), repeats: true) { _ in
                        if workoutManager.builder!.elapsedTime.rounded() >= (hapticDelayMinutes * 60)
                        {
                            print("units : " + String(distanceUnit))
                        if !onTarget && lastHapticFeedbackTime.timeIntervalSinceNow.rounded() <= -(hapticFrequencyMinutes * 60) {

                            if hapticFeedbackEnabled{
                                WKInterfaceDevice.current().play(.stop)
                                lastHapticFeedbackTime = Date()
                            }
                        }
                    }
                }
                
            }
        }
       // .sheet(isPresented: $showingSummaryView) {
       //     SummaryView()
       //         .environmentObject(workoutManager)
       // }
    }
    
    private func speedIndicator() -> String{
        if onTarget {
            return "hand.thumbsup"
        }
        else if currentZone(for: workoutManager.heartRate) < targetZone {
            return "arrow.up"
        }
        else if currentZone(for: workoutManager.heartRate) > targetZone {
            return "arrow.down"
        }
        else {return "hands.thumbsup"}
    }
    
    private func calculateAveragePace() -> String {
        guard let builder = workoutManager.builder else { return "Not Moving" }
        let elapsedTime = builder.elapsedTime(at: Date())
        
        var distance: Double = 0
        var distanceUnit: String = "km"
        if String(distanceUnit) == "miles"
        {
           let  distance = ((workoutManager.distance / 1000) * 0.621371)
           let  distanceUnit = "per mile"
        }
        if String(distanceUnit) == "kilometers"
        {
            let  distance = (workoutManager.distance / 1000)
            let  distanceUnit = "per km"
        }

        guard distance > 0.00001 else { return "Not Moving" }

        // Calculate pace in minutes per kilometer
        let paceInSecondsPerKm = elapsedTime / distance
        let minutes = Int(paceInSecondsPerKm) / 60
        let seconds = Int(paceInSecondsPerKm) % 60

        // Format the result as a string
        return String(format: "%02d\"%02d " + distanceUnit, minutes, seconds)
    }

    private func bpmColor(for heartRate: Double, position: String, targetSensitive: Bool) -> Color {
        let color: Color
        switch heartRate {
        case Double(z1min)...Double(z1max):
            color = targetSensitive ? (position == "Foreground" ? .white : .blue) : (position == "Foreground" ? .blue : .black)
        case Double(z2min)...Double(z2max):
            color = targetSensitive ? (position == "Foreground" ? .white : .green) : (position == "Foreground" ? .green : .black)
        case Double(z3min)...Double(z3max):
            color = targetSensitive ? (position == "Foreground" ? .white : .yellow) : (position == "Foreground" ? .yellow : .black)
        case Double(z4min)...Double(z4max):
            color = targetSensitive ? (position == "Foreground" ? .white : .orange) : (position == "Foreground" ? .orange : .black)
        case Double(z5min)...Double(z5max):
            color = targetSensitive ? (position == "Foreground" ? .white : .red) : (position == "Foreground" ? .red : .black)
        default:
            color = .white
        }
        return color
    }
    
    private func currentZone(for heartRate: Double) -> Int {
        switch heartRate {
        case Double(z1min)...Double(z1max):
            return 1
        case Double(z2min)...Double(z2max):
            return 2
        case Double(z3min)...Double(z3max):
            return 3
        case Double(z4min)...Double(z4max):
            return 4
        case Double(z5min)...Double(z5max):
            return 5
        default: return 0
        }
    }
}

struct MetricsView_Previews: PreviewProvider {
    static var previews: some View {
        MetricsView(targetZone: 3).environmentObject(WorkoutManager())
    }
}

private struct MetricsTimelineSchedule: TimelineSchedule {
    var startDate: Date

    init(from startDate: Date) {
        self.startDate = startDate
    }

    func entries(from startDate: Date, mode: TimelineScheduleMode) -> PeriodicTimelineSchedule.Entries {
        PeriodicTimelineSchedule(
            from: self.startDate,
            by: (mode == .lowFrequency ? 1.0 : 1.0 / 30.0)
        ).entries(
            from: startDate,
            mode: mode
        )
    }
}
