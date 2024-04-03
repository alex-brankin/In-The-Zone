//
//  HRView.swift
//  InTheZone
//
//  Created by Alex Brankin on 02/04/2024.
//

import Foundation
import HealthKit
import SwiftUI

struct HRView: View {
    @State private var heartRate: Double = 0.0

    var body: some View {
        VStack {
            Text("Heart Rate")
                .font(.largeTitle)
            Text("\(heartRate, specifier: "%.0f") BPM")
                .font(.title)
        }
        .onAppear {
            fetchHeartRateData { newHeartRate in
                heartRate = newHeartRate
            }
        }
    }
}

func fetchHeartRateData(completion: @escaping (Double) -> Void) {
    let healthStore = HKHealthStore()
    let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
    let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictStartDate)
    
    let query = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
        guard let samples = samples as? [HKQuantitySample] else {
            completion(0.0) // If there are no samples or error, set heart rate to 0.0
            return
        }
        
        if let sample = samples.last {
            let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
            let heartRate = sample.quantity.doubleValue(for: heartRateUnit)
            completion(heartRate)
        } else {
            completion(0.0) // If there are no samples, set heart rate to 0.0
        }
    }
    
    healthStore.execute(query)
}

struct HRView_Previews: PreviewProvider {
    static var previews: some View {
        HRView()
    }
}
