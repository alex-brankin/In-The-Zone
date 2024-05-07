//
//  InTheZone
//
//  Created by Alex Brankin on 02/03/2024.
//
// The BPMZonesCharts view in SwiftUI visualizes heart rate data from a workout using line charts and sector marks
// within a SwiftUI Chart view. It is designed to display heart rate data by time and to highlight heart rate zones
// with different colours, providing a graphical representation of the user's performance during their last workout.
// The view dynamically updates with new data on appearance and handles errors with user feedback. It also features
// an interactive pie chart showing the percentage of time spent in the target zone, enhancing the user experience
// by making heart rate zones visually compelling.

import SwiftUI
import HealthKit
import Charts


struct BPMZonesCharts: View {
    @ObservedObject var workoutAnalyzer: WorkoutAnalyzer
    @Environment(\.colorScheme) var colorScheme
    let healthManager = HealthKitManager()
    @State private var error: Error?
    
    let zoneColorMap: [String: Color] = [
        "Zone 1": .blue,
        "Zone 2": .green,
        "Zone 3": .yellow,
        "Zone 4": .orange,
        "Zone 5": .red
    ]
    
    let shortZoneColorMap: [String: Color] = [
        "z1": .blue,
        "z2": .green,
        "z3": .yellow,
        "z4": .orange,
        "z5": .red
    ]
    
    var body: some View {
        VStack {
            Text("Your Last Workout").font(.system(size: 20, weight: .bold))
            HStack {
                Spacer()
                if !workoutAnalyzer.heartRates.isEmpty {
                    // SwiftUI Line Chart
                    Chart(workoutAnalyzer.heartRateData) { data in
                        LineMark(
                            x: .value("Time", data.timestamp),
                            y: .value("BPM", data.rate)
                        )
                        .foregroundStyle(colorScheme == .dark ? Color.gray : Color.gray.opacity(0.5))
                        
                        
                        ForEach(workoutAnalyzer.zoneDefinitions, id: \.max) { zone in
                            RuleMark(y: .value("Max", zone.max))
                                .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
                                .foregroundStyle(zone.color.opacity(0.75))
                        }
                    }
                    .frame(height: 160)
                    .padding()
                } else if let error = error {
                    Text("Error: \(error.localizedDescription)")
                        .foregroundColor(.red)
                        .padding()
                } else {
                    // Display an empty state with a ProgressView
                    ProgressView("Fetching BPM...")
                        .frame(width: 160, height: 160)
                        .padding()
                }
                
                let targetZoneIndex = Int(workoutAnalyzer.metadataValues["targetZone"] ?? 0.0)
                let targetZoneLabel = "Zone \(targetZoneIndex)"
                
                // Now fetch the color for this label from the zoneColorMap
                let targetZoneColor = zoneColorMap[targetZoneLabel] ?? .gray
                
                // Display the target zone text with the correct color
                
                VStack {
                    ZStack {
                        Chart(workoutAnalyzer.zoneCounter) { zone in
                            SectorMark(
                                angle: .value(
                                    Text(verbatim: zone.zone),
                                    zone.value
                                ),
                                innerRadius: .ratio(0.6)
                            )
                            .foregroundStyle(zoneColorMap[zone.zone] ?? .gray)
                        }
                        .frame(width: 160, height: 160)
                        .padding(.top, -5)
                        
                        
                        let targetZoneIndex = Int(workoutAnalyzer.metadataValues["targetZone"] ?? 0.0)  //
                        let targetZoneLabel = "Zone \(targetZoneIndex)"
                        let targetZoneColor = zoneColorMap[targetZoneLabel] ?? .gray
                        
                        Text(String(format: "%.0f%%", workoutAnalyzer.targetZonePercentage ?? 0))
                            .font(.system(size: 30))
                            .fontWeight(.bold)
                            .foregroundColor(targetZoneColor)
                        
                    }
                }
                Spacer()
            }.padding(.top, -15)
            let targetZoneIndex = Int(workoutAnalyzer.metadataValues["targetZone"] ?? 0.0)
            let targetZoneLabel = "Zone \(targetZoneIndex)"
            let targetZoneColor = zoneColorMap[targetZoneLabel] ?? .gray
            Text("Target: \(targetZoneLabel)")
                .font(.headline)
                .foregroundColor(targetZoneColor)
                .padding(.top, -30)
            
            HStack {
                ForEach(workoutAnalyzer.zoneCounter, id: \.id) { zone in
                    HStack {
                        
                        let shortKey = "z" + zone.zone.filter { $0.isNumber }
                        
                        Circle()
                            .fill(shortZoneColorMap[shortKey] ?? .gray)
                            .frame(width: 10, height: 10)
                        Text(shortKey)
                            .font(.system(size: 12))
                    }
                }
            }.padding(.top, -10)
            
                .onAppear {
                    workoutAnalyzer.fetchLatestWorkout { workout in
                        if let workout = workout {
                            workoutAnalyzer.processWorkout(workout: workout)
                            print("Successfully fetched latest workout")
                        } else {
                            print("Failed to fetch the latest workout.")
                        }
                    }
                }
            
        }
    }
    
}
