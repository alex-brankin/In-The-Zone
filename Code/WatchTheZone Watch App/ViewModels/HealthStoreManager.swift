
//
//  HealthStoreManager.swift
//  WatchTheZone Watch App
//
//  Created by Alex Brankin on 06/04/2024.
//
// The HealthStoreManager class in the WatchTheZone Watch App is a singleton designed to manage and
// provide centralized access to the HealthKit store. It handles HealthKit authorization, requesting
// permissions for specific health data types such as heart rate and calories burned to ensure the
// app can access and store workout-related data. This management ensures the app adheres to privacy
// and security norms while facilitating health data integration and usage throughout the
// application.


import HealthKit

class HealthStoreManager {
    static let shared = HealthStoreManager()
    let healthStore: HKHealthStore

    private init() {
        healthStore = HKHealthStore()
    }

    // Request authorization to access HealthKit.
    func requestAuthorization() {
        // The quantity type to write to the health store.
        let typesToShare: Set = [
            HKQuantityType.workoutType()
        ]
        
        // The quantity types to read from the health store.
        let typesToRead: Set = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKQuantityType.quantityType(forIdentifier: .distanceCycling)!,
            HKObjectType.activitySummaryType()
        ]
        
        var allAuthorized = true
        for type in typesToRead {
            if healthStore.authorizationStatus(for: type) != .sharingAuthorized {
                allAuthorized = false
                break
            }
        }
        
        if !allAuthorized {
            healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
                if success {
                    // Authorization granted, do nothing
                } else {
                    // Authorization denied or error occurred
                    if let error = error {
                        print("Authorization failed: \(error.localizedDescription)")
                    } else {
                        print("Authorization denied")
                    }
                }
            }        }
    }

}
