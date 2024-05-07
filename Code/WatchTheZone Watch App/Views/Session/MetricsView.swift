//
//  WatchTheZone
//
//  Created by Alex Brankin on 13/03/2024.
//
// The MetricsView in the WatchTheZone Watch App dynamically displays real-time workout metrics
// during physical activity. It updates continuously using a TimelineView, showing elapsed time,
// heart rate, and exercise zones. Metrics like pace and distance are also prominently featured,
// color-coded to reflect different performance zones. Visual indicators such as arrows and
// thumbs-up icons provide instant feedback on whether the user is meeting their target zone. This
// view is essential for users to monitor and adjust their effort during workouts effectively.

import SwiftUI
import HealthKit

struct MetricsView: View {
    var targetZone: Int
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var showingSummaryView = false
    @EnvironmentObject var workoutUIManager: WorkoutUIManager
    
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
                            .foregroundColor(workoutUIManager.zoneColor(for: targetZone))
                            .frame(height: 20)
                            .cornerRadius(8)
                        Text("Target Zone \(targetZone)")
                            .foregroundColor(.black)
                            .font(.system(size: 14))
                    }.padding(.bottom, -15)
                    HStack{
                        Text(workoutManager.heartRate.formatted(.number.precision(.fractionLength(0))))
                            .foregroundColor(workoutUIManager.zoneColor(for: workoutManager.currentZone))
                        Text(" bpm")
                            .foregroundColor(workoutUIManager.zoneColor(for: workoutManager.currentZone))
                            .font(.system(size: 25))
                        Text(" ")
                            .font(.system(size: 30))
                        Image(systemName: speedIndicator())
                            .foregroundColor(workoutUIManager.zoneColor(for: workoutManager.currentZone))
                            .font(.system(size: 30))
                    }
                    .padding(.bottom, -6)
                    ZStack {
                        Rectangle()
                            .foregroundColor(workoutUIManager.zoneColor(for: workoutManager.currentZone))
                            .frame(height: 20)
                            .cornerRadius(8)
                        Text("Zone \(workoutManager.currentZone) (\(workoutManager.currentZoneMin) - \(workoutManager.currentZoneMax))")
                            .foregroundColor(.black)
                            .font(.system(size: 14))
                    }
                }
                Text(workoutManager.pace).font(.system(size: 25)).padding(.top, -4)
                Text(workoutManager.formattedDistance).font(.system(size: 25))
            }
            .font(.system(.title, design: .rounded).monospacedDigit().lowercaseSmallCaps())
            .frame(maxWidth: .infinity, alignment: .leading)
            .ignoresSafeArea(edges: .bottom)
            .scenePadding()
            .onAppear {
                
                
            }
        }
    }
    
    private func speedIndicator() -> String{
        if workoutManager.onTarget {
            return "hand.thumbsup"
        }
        else if workoutManager.currentZone < targetZone {
            return "arrow.up"
        }
        else if workoutManager.currentZone > targetZone {
            return "arrow.down"
        }
        else {return "hands.thumbsup"}
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
