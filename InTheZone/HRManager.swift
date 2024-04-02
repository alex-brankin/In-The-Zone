//
//  HRManager.swift
//  InTheZone
//
//  Created by Alex Brankin on 02/04/2024.
//

import Foundation
import HealthKit
func fetchHeartRateData() {
    let healthStore = HKHealthStore()
    let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
    let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictStartDate)
    
    let query = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
        guard samples is [HKQuantitySample] else { return }
        
    }
    
    healthStore.execute(query)
}
