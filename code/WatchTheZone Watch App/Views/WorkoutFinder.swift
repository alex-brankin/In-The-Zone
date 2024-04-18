//
//  WorkoutFinder.swift
//  WatchTheZone Watch App
//
//  Created by Alex Brankin on 16/04/2024.
//

import Foundation
import HealthKit

class WorkoutFinder: NSObject, ObservableObject  {
    let healthStore = HKHealthStore()
    let brandMetadataKey = "Brand"

    // Function to retrieve workouts with the brand "InTheZone"
    func retrieveWorkouts(completion: @escaping ([HKWorkout]?, Error?) -> Void) {
        // Check authorization status
        let authorizationStatus = healthStore.authorizationStatus(for: .workoutType())

        switch authorizationStatus {
        case .notDetermined:
            // Authorization not determined, request authorization
            requestAuthorization(completion: completion)
        case .sharingDenied:
            // Authorization denied, handle accordingly
            completion(nil, NSError(domain: "AuthorizationError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Authorization denied"]))
        case .sharingAuthorized:
            // Authorization already granted, proceed with fetching workouts
            fetchWorkouts(completion: completion)
        @unknown default:
            // Handle unknown cases
            completion(nil, NSError(domain: "AuthorizationError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unknown authorization status"]))
        }
    }

    // Function to request authorization to access HealthKit data
    private func requestAuthorization(completion: @escaping ([HKWorkout]?, Error?) -> Void) {
        // The quantity type to write to the health store.
        let typesToShare: Set<HKSampleType> = []

        // The quantity types to read from the health store.
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.workoutType()
            // Add other types you want to read here
        ]

        // Request authorization for those quantity types.
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
            if success {
                // Authorization granted, proceed with fetching workouts
                self.fetchWorkouts(completion: completion)
            } else {
                // Authorization denied or error occurred
                if let error = error {
                    print("Authorization failed: \(error.localizedDescription)")
                } else {
                    print("Authorization denied")
                }
                completion(nil, error)
            }
        }
    }

    // Function to fetch workouts after authorization is granted
    private func fetchWorkouts(completion: @escaping ([HKWorkout]?, Error?) -> Void) {
        // Create a predicate to filter workouts based on metadata
        let predicate = HKQuery.predicateForObjects(withMetadataKey: brandMetadataKey, allowedValues: ["InTheZone"])

        // Create a sort descriptor to sort workouts by start date in descending order
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        // Create a query to fetch workouts matching the predicate and sorted by start date
        let query = HKSampleQuery(sampleType: .workoutType(),
                                  predicate: nil,
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
}

