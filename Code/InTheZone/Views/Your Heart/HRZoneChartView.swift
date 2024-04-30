//
//  InTheZone
//
//  Created by Alex Brankin on 02/03/2024.
//

import SwiftUI
import HealthKit
import SwiftUICharts
import Charts


struct BPMZonesCharts: View {
    @Environment(\.colorScheme) var colorScheme
    let healthManager = HealthKitManager()
    @State private var bpmData: [Double] = []
    @State private var error: Error?
    @State private var zonePercentages: [Double] = [60, 70, 80, 90, 100]
    @State private var zoneCounter: [ZoneCounter] = []
    @State private var targetZonePercentage: Double? = nil
    @State private var zoneDefinitions: [ZoneDefinition] = []
    @State private var heartRateData: [HeartRateData] = []
    @State private var heartRates: [Double] = []
    @State private var metadataValues: [String: Double] = [:]
    @State private var zoneCounts: [String: Int] = [
        "Zone 1": 0,
        "Zone 2": 0,
        "Zone 3": 0,
        "Zone 4": 0,
        "Zone 5": 0
    ]
    
    let maxHeartRate: Double = 200
    let zoneLabels: [String] = ["Zone 1", "Zone 2", "Zone 3", "Zone 4", "Zone 5"]
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
                    if !heartRates.isEmpty {
                        // SwiftUI Line Chart
                        Chart(heartRateData) { data in
                            LineMark(
                                x: .value("Time", data.timestamp),
                                y: .value("BPM", data.rate)
                            )
                            .foregroundStyle(colorScheme == .dark ? Color.gray : Color.gray.opacity(0.5))


                            ForEach(zoneDefinitions, id: \.max) { zone in
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
         
                let targetZoneIndex = Int(metadataValues["targetZone"] ?? 0.0)
                let targetZoneLabel = "Zone \(targetZoneIndex)"

                // Now fetch the color for this label from the zoneColorMap
                let targetZoneColor = zoneColorMap[targetZoneLabel] ?? .gray

                // Display the target zone text with the correct color
              
                    VStack {
                        ZStack {
                        Chart(zoneCounter) { zone in
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
                        
                            
                            let targetZoneIndex = Int(metadataValues["targetZone"] ?? 0.0)  //
                            let targetZoneLabel = "Zone \(targetZoneIndex)"
                            let targetZoneColor = zoneColorMap[targetZoneLabel] ?? .gray
                            
                            Text(String(format: "%.0f%%", targetZonePercentage ?? 0))
                                                        .font(.system(size: 30))
                                                        .fontWeight(.bold)
                                                        .foregroundColor(targetZoneColor)
                                                
                    }

                        
                    
                 }
                
                Spacer()
            }.padding(.top, -15)
            let targetZoneIndex = Int(metadataValues["targetZone"] ?? 0.0)
            let targetZoneLabel = "Zone \(targetZoneIndex)"
            let targetZoneColor = zoneColorMap[targetZoneLabel] ?? .gray
            Text("Target: \(targetZoneLabel)")
                .font(.headline)
                .foregroundColor(targetZoneColor)
                .padding(.top, -30)

            HStack {
                ForEach(zoneCounter, id: \.id) { zone in
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

        }.onAppear{
            fetchLatestWorkout()
            }
    }
            
    private func calculateTargetZonePercentage(){
        // Calculate the total value across all zones
        let total = zoneCounter.reduce(0.0) { $0 + $1.value }
        
        // Ensure there is a meaningful total to avoid division by zero
        if total == 0 {
            print("Total zone value is zero, cannot calculate percentages")
        }
        
        // Get the target zone index from metadata and construct its label
        let targetZoneIndex = Int(metadataValues["targetZone"] ?? 0.0)
        let targetZoneLabel = "Zone \(targetZoneIndex)"  // Example: "Zone 1"

        // Find the value for the target zone
        if let targetZone = zoneCounter.first(where: { $0.zone == targetZoneLabel }) {
            let targetZoneValue = targetZone.value
            let localTargetZonePercentage = (targetZoneValue / total) * 100
            
            // Return the calculated percentage
            targetZonePercentage = localTargetZonePercentage
        } else {
            print("Target zone not found in the data")

        }
    }

    private func fetchLatestWorkout() {
        print("Fetching Latest Workout")
        let brandPredicate = HKQuery.predicateForObjects(withMetadataKey: HKMetadataKeyWorkoutBrandName, allowedValues: ["InTheZone"])
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: HKObjectType.workoutType(), predicate: brandPredicate, limit: 1, sortDescriptors: [sortDescriptor]) { _, samples, error in
            guard let workouts = samples as? [HKWorkout], let latestWorkout = workouts.first else {
                print("Could not fetch workouts: \(String(describing: error))")
                return
            }
            
            let metadataKeys = [
                        "targetZone", "zone1Min", "zone1Max", "zone2Min", "zone2Max",
                        "zone3Min", "zone3Max", "zone4Min", "zone4Max", "zone5Min", "zone5Max"
                    ]

            var localMetadataValues: [String: Double] = [:]
            var localZoneDefinitions: [ZoneDefinition] = []
            let colors: [Color] = [.blue, .green, .yellow, .orange, .red]
            var colorIndex = 0 // to cycle through colors array

            // Check each key if it contains the expected metadata
            var doubleValue: Double = 0.0
            metadataKeys.forEach { key in
                print("Key : \(key)")
                print("Value : \(latestWorkout.metadata?[key] ?? "Missing")")
                if let stringValue = latestWorkout.metadata?[key] as? String {
                    doubleValue = Double(stringValue) ?? 0
                    localMetadataValues[key] = doubleValue
                    
                }
                    // Add to zoneDefinitions if the key ends with "Max"
                if key.contains("Min")  {
                        print("Key : \(key) - Value : \(doubleValue)")
                        let zoneDefinition = ZoneDefinition(max: doubleValue, color: colors[colorIndex % colors.count])
                        localZoneDefinitions.append(zoneDefinition)
                        colorIndex += 1 // increment color index to use next color
                    }
                    }


            DispatchQueue.main.async {
                self.metadataValues = localMetadataValues
                self.zoneDefinitions = localZoneDefinitions // Properly update the state
                print("Metadata Values: \(self.metadataValues)")
                print("Zone Definitions: \(self.zoneDefinitions)")
                self.fetchHeartRateData(for: latestWorkout)
            }
        }

        healthStore.execute(query)
    }

    private func fetchHeartRateData(for workout: HKWorkout) {
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else { return }
        let predicate = HKQuery.predicateForSamples(withStart: workout.startDate, end: workout.endDate, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        
        let query = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { _, samples, error in
            guard let samples = samples as? [HKQuantitySample] else { return }
            
            DispatchQueue.main.async {
                self.heartRateData = samples.map { HeartRateData(timestamp: $0.startDate, rate: $0.quantity.doubleValue(for: HKUnit(from: "count/min")), color: .gray) }
                self.heartRates = samples.map { $0.quantity.doubleValue(for: HKUnit(from: "count/min")) }
                self.categorizeHeartRates()  // Call the categorization function after updating heartRates
                self.calculateTargetZonePercentage()

            }
        }
        
        healthStore.execute(query)
    }
    
    private func colorForHeartRate() -> Color {
        var heartRateColor: Color = .gray
        for (index, rate) in heartRateData.enumerated() {
            
            for i in 0...4 {
                let minKey = "zone\(i+1)Min"
                let maxKey = "zone\(i+1)Max"
                
                if let min = metadataValues[minKey], let max = metadataValues[maxKey], rate.rate >= min && rate.rate <= max {
                    // Correct the zone lookup and update the color
                    let zoneLabel = "Zone \(i+1)"
                    if let color = zoneColorMap[zoneLabel] {
                        // Update the color of the heart rate data in place
                        var updatedRate = rate
                        updatedRate.color = color
                        heartRateColor = color
                        heartRateData[index] = updatedRate
                        
                    }
                    break
                }
            }
        }
        return heartRateColor
    }
    private func categorizeHeartRates() {
        // Reset zone counts
        zoneCounts = zoneCounts.mapValues { _ in 0 }

        // Iterate through each heart rate and categorize it

        for rate in heartRates {
            for i in 0...4 {
                let minKey = "zone\(i+1)Min"
                let maxKey = "zone\(i+1)Max"

                if let min = metadataValues[minKey] as? Double, let max = metadataValues[maxKey] as? Double {
                    if rate >= min && rate <= max {
                        zoneCounts["Zone \(i+1)"]! += 1
                        break
                    }
                }
            }
        }

        // Convert zoneCounts to ZoneCounter objects and store in zoneCounter
        zoneCounter = zoneLabels.enumerated().compactMap { index, label in
            if let count = zoneCounts[label] {
                return ZoneCounter(zone: label, value: Double(count))
            }
            return nil
        }
        updateZonePercentages()
    }

    private func updateZonePercentages() {
        zonePercentages = zoneCounts.values.map(Double.init)  
    }
    
    // Function to calculate the percentage of max heart rate for each zone
    private func calculateZonePercentages() -> [Double] {
        let totalPercentage = zonePercentages.reduce(0, +)
        return zonePercentages.map { $0 / 100 * maxHeartRate / totalPercentage }
    }

    private func fetchBPMData() {
        healthManager.fetchBPMData { bpmData, error in
            if let error = error {
                self.error = error
            } else if let bpmData = bpmData {
                self.bpmData = bpmData
            }
        }
    }
}

struct BPMZonesCharts_Previews: PreviewProvider {
    static var previews: some View {
        BPMZonesCharts()
    }
}

