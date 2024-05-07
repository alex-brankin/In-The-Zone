//
//  InTheZone
//
//  Created by Alex Brankin on 02/03/2024.
//
// The WorkoutAnalyzer class integrates with HealthKit to
// analyze workout data, particularly focusing on heart rate metrics across defined zones. It processes workout data
// to fetch heart rates, calculates averages, peaks, and assesses performance against heart rate zones, managing
// both real-time and historical data. Additionally, it handles notification of achievements related to fitness
// goals and handles errors related to data fetching or processing. This class significantly relies on asynchronous
// calls and local data caching to provide a responsive user experience in the fitness tracking app.

import Foundation
import HealthKit
import SwiftUI

class WorkoutAnalyzer: NSObject, ObservableObject {
    @Published  var metadataValues: [String: Double] = [:]
    @Published  var zoneDefinitions: [ZoneDefinition] = []
    @Published  var heartRateData: [HeartRateData] = []
    @Published  var heartRates: [Double] = []
    @Published  var zoneCounts: [String: Int] = [
        "Zone 1": 0,
        "Zone 2": 0,
        "Zone 3": 0,
        "Zone 4": 0,
        "Zone 5": 0
    ]
    @Published  var zoneCounter: [ZoneCounter] = []
    @Published  var targetZonePercentage: Double? = nil
    @Published var zonePercentages: [Double] = [60, 70, 80, 90, 100]
    @Published var avgHeartRate: Int = 0
    @Published var peakHeartRate: Int = 0
    
    let zoneLabels: [String] = ["Zone 1", "Zone 2", "Zone 3", "Zone 4", "Zone 5"]

    let maxHeartRate: Double = 200
    
    func processWorkout(workout: HKWorkout) {
        
        retrieveHeartRateData(for: workout)
        print("Fetching Latest Workout")
        let brandPredicate = HKQuery.predicateForObjects(withMetadataKey: HKMetadataKeyWorkoutBrandName, allowedValues: ["InTheZone"])
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: HKObjectType.workoutType(), predicate: brandPredicate, limit: 1, sortDescriptors: [sortDescriptor]) { _, samples, error in
            guard let workouts = samples as? [HKWorkout], let latestWorkout1 = workouts.first else {
                print("Could not fetch workouts: \(String(describing: error))")
                return
            }
            let latestWorkout = workout
            
            let metadataKeys = [
                "targetZone", "zone1Min", "zone1Max", "zone2Min", "zone2Max",
                "zone3Min", "zone3Max", "zone4Min", "zone4Max", "zone5Min", "zone5Max"
            ]
            
            var localMetadataValues: [String: Double] = [:]
            var localZoneDefinitions: [ZoneDefinition] = []
            let colors: [Color] = [.blue, .green, .yellow, .orange, .red]
            var colorIndex = 0
            
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
                self.categorizeHeartRates()
                self.calculateTargetZonePercentage()

            }
        }
        
        healthStore.execute(query)
    }

    private func categorizeHeartRates() {

        zoneCounts = zoneCounts.mapValues { _ in 0 }

        // Iterate through each heart rate and categorize it

        for rate in heartRates {
            print("found heartrate : \(rate)")
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
        print("Zone Counts : \(zoneCounts)")

        // Convert zoneCounts to ZoneCounter objects and store in zoneCounter
        zoneCounter = zoneLabels.enumerated().compactMap { index, label in
            if let count = zoneCounts[label] {
                return ZoneCounter(zone: label, value: Double(count))
            }
            return nil
        }
        updateZonePercentages()
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
        let targetZoneLabel = "Zone \(targetZoneIndex)"

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
    
    private func updateZonePercentages() {
        zonePercentages = zoneCounts.values.map(Double.init)
    }
    
    // Function to calculate the percentage of max heart rate for each zone
    private func calculateZonePercentages() -> [Double] {
        let totalPercentage = zonePercentages.reduce(0, +)
        return zonePercentages.map { $0 / 100 * maxHeartRate / totalPercentage }
    }
    
    func retrieveHeartRateData(for workout: HKWorkout) {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            return
        }

        let predicate = HKQuery.predicateForSamples(withStart: workout.startDate, end: workout.endDate, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: heartRateType, quantitySamplePredicate: predicate, options: [.discreteAverage, .discreteMax]) { _, result, error in
            guard error == nil, let result = result else {
                print("Error retrieving heart rates: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            let averageHeartRate = result.averageQuantity()?.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
            let maxHeartRate = result.maximumQuantity()?.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
            
            DispatchQueue.main.async {
                self.avgHeartRate = Int((averageHeartRate ?? 0).rounded())
                self.peakHeartRate = Int((maxHeartRate ?? 0).rounded())
            }
        }
        
        HKHealthStore().execute(query)
    }
    
    func fetchLatestWorkout(completion: @escaping (HKWorkout?) -> Void) {
        print("Fetching Latest Workout")
        let brandPredicate = HKQuery.predicateForObjects(withMetadataKey: HKMetadataKeyWorkoutBrandName, allowedValues: ["InTheZone"])
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: HKObjectType.workoutType(), predicate: brandPredicate, limit: 1, sortDescriptors: [sortDescriptor]) { _, samples, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Could not fetch workouts: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                guard let workouts = samples as? [HKWorkout], let latestWorkout = workouts.first else {
                    print("No workouts returned")
                    completion(nil)
                    return
                }
                
                completion(latestWorkout)
            }
        }
        healthStore.execute(query)
    }



}


