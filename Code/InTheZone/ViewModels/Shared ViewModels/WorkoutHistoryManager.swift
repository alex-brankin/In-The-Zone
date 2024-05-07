//
//  WorkoutHistoryManager.swift
//  InTheZone
//
//  Created by Alex Brankin on 23/04/2024.
//
// The WorkoutHistoryManager class is designed to interact with HealthKit to manage and retrieve detailed
// workout data. It fetches workout records, including total distance, start and end
// times, average and peak heart rates, and calories burned, leveraging HealthKit's capabilities to query and handle
// health-related data efficiently. The class also formats and manages heart rate zones, updating published
// properties that are observed by the app's user interface, ensuring real-time data presentation and updates.

import Foundation
import HealthKit

class WorkoutHistoryManager: NSObject, ObservableObject {
    
    private var healthStore: HKHealthStore {
            HealthStoreManager.shared.healthStore
        }
    
    //let healthStore = HKHealthStore()
    let brandMetadataKey = "Brand"
    
    @Published var totalDistance: String = ""
    @Published var startDate: String = ""
    @Published var endDate: String = ""
    @Published var avgHeartRate: String = ""
    @Published var peakHeartRate: String = ""
    @Published var caloriesBurned: Int = 0
    @Published var targetZone: Int = 0
    @Published var zone1Min: Int = 0
    @Published var zone1Max: Int = 0
    @Published var zone2Min: Int = 0
    @Published var zone2Max: Int = 0
    @Published var zone3Min: Int = 0
    @Published var zone3Max: Int = 0
    @Published var zone4Min: Int = 0
    @Published var zone4Max: Int = 0
    @Published var zone5Min: Int = 0
    @Published var zone5Max: Int = 0
    
    
    func getWorkouts(completion: @escaping ([HKWorkout]?, Error?) -> Void) {
        // Create a predicate to filter workouts based on metadata
        let predicate = HKQuery.predicateForObjects(withMetadataKey: HKMetadataKeyWorkoutBrandName, allowedValues: ["InTheZone"])
        
        // Create a sort descriptor to sort workouts by start date in descending order
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        // Create a query to fetch workouts matching the predicate and sorted by start date
        let query = HKSampleQuery(sampleType: .workoutType(),
                                  predicate: predicate,
                                  limit: HKObjectQueryNoLimit,
                                  sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            guard let workouts = samples as? [HKWorkout], error == nil else {
                completion(nil, error)
                return
            }
            completion(workouts, nil)
        }
        
        // Execute the query
        healthStore.execute(query)
    }
    
    func getWorkoutDetails(for workout: HKWorkout) -> Void
    {
        let distanceInKm = (Double(workout.totalDistance?.doubleValue(for: HKUnit.meter()) ?? 0) / 1000)
        let roundedDistance = (distanceInKm * 100).rounded() / 100
        self.totalDistance =  String("\(roundedDistance) km")
        self.startDate = formattedDate(for: workout.startDate)
        self.endDate = formattedDate(for: workout.endDate)
        
        self.getHeartRate(for: workout, queryType: .average) { heartRate in
            DispatchQueue.main.async {
                if let heartRate = heartRate {
                    self.avgHeartRate = heartRate
                } else {
                    self.avgHeartRate = "Missing"
                }
            }
        }
        
        self.getHeartRate(for: workout, queryType: .peak) { heartRate in
            DispatchQueue.main.async {
                if let heartRate = heartRate {
                    self.peakHeartRate = heartRate
                } else {
                    self.peakHeartRate = "Missing"
                }
            }
        }
        self.caloriesBurned = Int(workout.totalEnergyBurned?.doubleValue(for: HKUnit.kilocalorie()) ?? 0)
        
        print("Metadata : \(workout.metadata)")
        if let metadata = workout.metadata {
            for (key, value) in metadata {
                if let stringValue = value as? String, let intValue = Int(stringValue) {
                    print("Key : \(key) - Value \(intValue)")
                    switch key {
                    case "zone1Min":
                        self.zone1Min = intValue
                    case "zone1Max":
                        self.zone1Max = intValue
                    case "zone2Min":
                        self.zone2Min = intValue
                    case "zone2Max":
                        self.zone2Max = intValue
                    case "zone3Min":
                        self.zone3Min = intValue
                    case "zone3Max":
                        self.zone3Max = intValue
                    case "zone4Min":
                        self.zone4Min = intValue
                    case "zone4Max":
                        self.zone4Max = intValue
                    case "zone5Min":
                        self.zone5Min = intValue
                    case "zone5Max":
                        self.zone5Max = intValue
                    case "targetZone":
                        self.targetZone = intValue
                    default:
                        print("not an InTheZone key")
                    }
                } else {
                    print("Failed to convert \(value) to Int for key \(key)")
                }

            }
        }
        
    }
    
    private func formattedDate(for date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm, MMMM d, yyyy"
        return dateFormatter.string(from: date)
    }
    
    enum HeartRateQueryType {
        case average, peak
    }
    func getHeartRate(for workout: HKWorkout, queryType: HeartRateQueryType, completion: @escaping (String?) -> Void) {
        // Define the heart rate type
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            completion(nil)
            return
        }
        
        // Create a predicate to query heart rate samples for the workout's time interval
        let predicate = HKQuery.predicateForSamples(withStart: workout.startDate, end: workout.endDate, options: .strictStartDate)
        
        // Determine the options based on the query type
        var options: HKStatisticsOptions
        switch queryType {
        case .average:
            options = .discreteAverage
        case .peak:
            options = .discreteMax
        }
        
        // Create a query to retrieve heart rate samples
        let query = HKStatisticsQuery(quantityType: heartRateType, quantitySamplePredicate: predicate, options: options) { (_, result, error) in
            guard let result = result else {
                completion(nil)
                return
            }
            
            // Get the heart rate value based on the query type
            var heartRateValue: Double?
            switch queryType {
            case .average:
                heartRateValue = result.averageQuantity()?.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
            case .peak:
                heartRateValue = result.maximumQuantity()?.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
            }
            
            // Format the heart rate value
            if let heartRateValue = heartRateValue {
                let formattedHeartRate = String(format: "%.0f bpm", heartRateValue)
                completion(formattedHeartRate) // Return the formatted heart rate value
            } else {
                completion(nil)
            }
        }
        
        // Execute the query
        HKHealthStore().execute(query)
    }



}
