//
//  WorkoutFinder.swift
//  InTheZone
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
