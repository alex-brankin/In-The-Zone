//
//  WorkoutsDetailView.swift
//  InTheZone
//
//  Created by Alex Brankin on 06/04/2024.
//
// The WorkoutDetailView in SwiftUI provides a detailed breakdown of a specific workout, including statistics such
// as start and end times, distance, duration, and heart rate metrics (average and peak). It uses a WorkoutAnalyzer
// object to fetch and process data displayed in various sections, with colours indicating different heart rate
// zones. The view integrates charts to visualize heart rate over time and heart rate zone distributions, enhancing
// user interaction by displaying comprehensive fitness data effectively. 

import Charts
import SwiftUI
import HealthKit


struct WorkoutDetailView: View {
    @ObservedObject var workoutAnalyzer: WorkoutAnalyzer
    
    @Environment(\.colorScheme) var colorScheme
    let workout: HKWorkout
    let healthManager = HealthKitManager()
    //let workoutAnalyzer = WorkoutAnalyzer()

    @State private var error: Error?
    @State private var zoneMinAndMax: [ZoneMinAndMax] = []
    
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
            VStack {
                Text("Workout Details")
                    .font(.title)
                    .foregroundColor(.gray)
                    .padding(.bottom, -5)
                
                VStack(alignment: .leading) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Start")
                                .foregroundColor(.red)
                            Text("\(formattedStartTime(for: workout))")
                                .font(.title2)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        
                        VStack(alignment: .leading) {
                            Text("End")
                                .foregroundColor(.red)
                            Text("\(formattedEndTime(for: workout))")
                                .font(.title2)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.vertical, 4)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Distance")
                                .foregroundColor(.red)
                            Text("\(String(format: "%.2f", Double(workout.totalDistance?.doubleValue(for: HKUnit.meter()) ?? 0) / 1000)) km")
                                .font(.title2)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        
                        VStack(alignment: .leading) {
                            Text("Duration")
                                .foregroundColor(.red)
                            Text("\(formattedDuration(for: workout))")
                                .font(.title2)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.vertical, 4)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Avg Heart Rate")
                                .foregroundColor(.red)
                            Text("\(workoutAnalyzer.avgHeartRate)")
                                .font(.title2)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        
                        VStack(alignment: .leading) {
                            Text("Peak Heart Rate")
                                .foregroundColor(.red)
                            Text("\(workoutAnalyzer.peakHeartRate)")
                                .font(.title2)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.vertical, 4)
                    
                    VStack(alignment: .leading) {
                        Text("Calories")
                            .foregroundColor(.red)
                        Text("\(Int(workout.totalEnergyBurned?.doubleValue(for: HKUnit.kilocalorie()) ?? 0))")
                            .font(.title2)
                    }
                    .padding(.vertical, 4)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                }
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding(.bottom, -10)
                .padding([.horizontal, .bottom])
            }
            .padding(.top, -30)
        }.padding(.top, -30)
        
        VStack {
            Text("Heart Rate").foregroundColor(.gray).padding(.bottom,-10)
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
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
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
        }.background(Color(.secondarySystemBackground))
            .cornerRadius(10)
            .shadow(radius: 5)
            .padding(.bottom, -10)
            .padding([.horizontal, .bottom])
        
        VStack {
            let targetZoneIndex = Int(workoutAnalyzer.metadataValues["targetZone"] ?? 0.0)
            let targetZoneLabel = "Zone \(targetZoneIndex)"
            // Now fetch the color for this label from the zoneColorMap
            let targetZoneColor = zoneColorMap[targetZoneLabel] ?? .gray
            
            Text("Target: \(targetZoneLabel)")
                .font(.headline)
                .foregroundColor(targetZoneColor)
                .padding(.bottom, 5)
                .padding(.top, 10)
                .frame(maxWidth: .infinity, alignment: .center)
            
            
            HStack(alignment: .center, spacing: 20) {
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
                    
                    Text(String(format: "%.0f%%", workoutAnalyzer.targetZonePercentage ?? 0))
                        .font(.system(size: 30))
                        .fontWeight(.bold)
                        .foregroundColor(targetZoneColor)
                }.padding(.bottom, 10)
                
                VStack {
                    ForEach(workoutAnalyzer.zoneCounter, id: \.id) { zone in
                        HStack {
                            let shortKey = "z" + zone.zone.filter { $0.isNumber }
                            
                            Circle()
                                .fill(shortZoneColorMap[shortKey] ?? .gray)
                                .frame(width: 10, height: 10)
                            Text(zone.zone)
                                .font(.system(size: 16))
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding([.horizontal, .bottom])
        .onAppear{
            workoutAnalyzer.processWorkout(workout: workout)
        }
        
    }
    
    private func formattedStartDate(for workout: HKWorkout) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        return dateFormatter.string(from: workout.startDate)
    }
    
    private func formattedStartTime(for workout: HKWorkout) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        return dateFormatter.string(from: workout.startDate)
    }
    
    private func formattedEndDate(for workout: HKWorkout) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm, MMMM d, yyyy"
        return dateFormatter.string(from: workout.endDate)
    }
    private func formattedEndTime(for workout: HKWorkout) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        return dateFormatter.string(from: workout.endDate)
    }
    
    private func formattedDuration(for workout: HKWorkout) -> String {
        let duration = Int(workout.duration)
        let hours = duration / 3600
        let minutes = (duration % 3600) / 60
        let seconds = duration % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
}
