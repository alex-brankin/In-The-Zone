//
//  WatchTheZone
//
//  Created by Alex Brankin on 13/03/2024.
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
    @AppStorage("zone1Min") private var zone1Min = ""
    @AppStorage("zone1Max") private var zone1Max = ""
    @AppStorage("zone2Min") private var zone2Min = ""
    @AppStorage("zone2Max") private var zone2Max = ""
    @AppStorage("zone3Min") private var zone3Min = ""
    @AppStorage("zone3Max") private var zone3Max = ""
    @AppStorage("zone4Min") private var zone4Min = ""
    @AppStorage("zone4Max") private var zone4Max = ""
    @AppStorage("zone5Min") private var zone5Min = ""
    @AppStorage("zone5Max") private var zone5Max = ""

  
    private var onTarget: Bool {
        targetZone == currentZone(for: workoutManager.heartRate)
    }

    
    @State private var lastHapticFeedbackTime = Date()
        
    var body: some View {
        TimelineView(MetricsTimelineSchedule(
            from: workoutManager.builder?.startDate ?? Date()
        )) { context in
            VStack(alignment: .leading) {
                ElapsedTimeView(elapsedTime: workoutManager.builder?.elapsedTime(at: context.date) ?? 0, showSubseconds: context.cadence == .live)
                    .foregroundStyle(.yellow)
                    .padding(.top, 5)
                    .padding(.bottom, -5)
                
                
                VStack(alignment: .leading){
                    ZStack {
                        Rectangle()
                            .foregroundColor(zoneColor(for: targetZone))
                            .frame(height: 20)
                            .cornerRadius(8)
                        Text("Target Zone " + String(targetZone))
                            .foregroundColor(.white)
                            .font(.system(size: 14))
                    }.padding(.bottom, -15)
                    HStack{
                        Text(workoutManager.heartRate.formatted(.number.precision(.fractionLength(0))))
                            .foregroundColor(bpmColor(for: workoutManager.heartRate, position: "Foreground", targetSensitive: false))
                        Text(" bpm").foregroundColor(bpmColor(for: workoutManager.heartRate, position: "Foreground", targetSensitive: false))
                            .font(.system(size: 25))
                        Text(" ")
                            .foregroundColor(bpmColor(for: workoutManager.heartRate, position: "Foreground", targetSensitive: false))
                            .font(.system(size: 30))
                        Image(systemName: speedIndicator()).foregroundColor(bpmColor(for: workoutManager.heartRate, position: "Foreground", targetSensitive: false))
                            .font(.system(size: 30))
                    }
                    .padding(.bottom, -6)
                    ZStack {
                        Rectangle()
                            .foregroundColor(bpmColor(for: workoutManager.heartRate, position: "Foreground", targetSensitive: false)) // Adjust color and opacity as needed
                            .frame(height: 20)
                            .cornerRadius(8)
                        
                        Text("Zone \(currentZone(for: workoutManager.heartRate)) \(zoneText(for: Double(currentZone(for: workoutManager.heartRate))))")
                            .foregroundColor(.white)
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
        var displayUnit: String = " per km"
        if String(distanceUnit) == "miles"
        {
           distance = ((workoutManager.distance / 1000) * 0.621371)
           displayUnit = "per mile"
        }
        if String(distanceUnit) == "kilometers"
        {
            distance = (workoutManager.distance / 1000)
            displayUnit = "per km"
        }
        guard distance > 0.00001 else { return "Not Moving" }

        // Calculate pace in minutes per kilometer
        let paceInSecondsPerKm = elapsedTime / distance
        let minutes = Int(paceInSecondsPerKm) / 60
        let seconds = Int(paceInSecondsPerKm) % 60

        return String(format: "%02d\"%02d " + displayUnit, minutes, seconds)
    }

    private func bpmColor(for heartRate: Double, position: String, targetSensitive: Bool) -> Color {
        let color: Color
        switch heartRate {
        case (Double(zone1Min) ?? 0)...(Double(zone1Max) ?? 0):
            color = targetSensitive ? (position == "Foreground" ? .white : .blue) : (position == "Foreground" ? .blue : .black)
        case (Double(zone2Min) ?? 0)...(Double(zone2Max) ?? 0):
            color = targetSensitive ? (position == "Foreground" ? .white : .green) : (position == "Foreground" ? .green : .black)
        case (Double(zone3Min) ?? 0)...(Double(zone3Max) ?? 0):
            color = targetSensitive ? (position == "Foreground" ? .white : .yellow) : (position == "Foreground" ? .yellow : .black)
        case (Double(zone4Min) ?? 0)...(Double(zone4Max) ?? 0):
            color = targetSensitive ? (position == "Foreground" ? .white : .orange) : (position == "Foreground" ? .orange : .black)
        case (Double(zone5Min) ?? 0)...(Double(zone5Max) ?? 0):
            color = targetSensitive ? (position == "Foreground" ? .white : .red) : (position == "Foreground" ? .red : .black)
        default:
            color = targetSensitive ? (position == "Foreground" ? .white : .blue) : (position == "Foreground" ? .blue : .black)
        }
        return color
    }
                                             
        private func zoneColor(for zone: Int) -> Color {
            let color: Color
            switch zone {
            case 1:
                color = .blue
            case 2:
                color = .green
            case 3:
                color = .yellow
            case 4:
                color = .orange
            case 5:
                color = .red
            default:
                color = .blue
            }
            return color
    }
    
    private func currentZone(for heartRate: Double) -> Int {
        switch heartRate {
        case (Double(zone1Min) ?? 0)...(Double(zone1Max) ?? 0):
            return 1
        case (Double(zone2Min) ?? 0)...(Double(zone2Max) ?? 0):
            return 2
        case (Double(zone3Min) ?? 0)...(Double(zone3Max) ?? 0):
            return 3
        case (Double(zone4Min) ?? 0)...(Double(zone4Max) ?? 0):
            return 4
        case (Double(zone5Min) ?? 0)...(Double(zone5Max) ?? 0):
            return 5
        default: return 0
        }
    }
    
    private func zoneText(for zone: Double) -> String {
        switch zone {
        case 1:
            return "(" + String(zone1Min) + " - " + String(zone1Max) + ")"
        case 2:
            return "(" + String(zone2Min) + " - " + String(zone2Max) + ")"
        case 3:
            return "(" + String(zone2Min) + " - " + String(zone3Max) + ")"
        case 4:
            return "(" + String(zone2Min) + " - " + String(zone4Max) + ")"
        case 5:
            return "(" + String(zone2Min) + " - " + String(zone5Max) + ")"
        default: return ""
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
