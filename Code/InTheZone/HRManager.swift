//
//  HRManager.swift
//  InTheZone
//
//  Created by Alex Brankin on 02/04/2024.
//

import HealthKit

class HealthKitManager: NSObject {
    let healthStore = HKHealthStore()
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false)
            return
        }
        
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let typesToShare: Set = [heartRateType]
        let typesToRead: Set = [heartRateType]
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
            completion(success)
        }
    }
    
    func fetchMostRecentHeartRate(completion: @escaping (Double?, Error?) -> Void) {
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: 1, sortDescriptors: nil) { (query, results, error) in
            guard let samples = results as? [HKQuantitySample], let sample = samples.first else {
                completion(nil, error)
                return
            }
            
            let heartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            completion(heartRate, nil)
        }
        
        healthStore.execute(query)
    }
}
