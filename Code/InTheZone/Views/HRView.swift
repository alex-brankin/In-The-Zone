//
//  HRView.swift
//  InTheZone
//
//  Created by Alex Brankin on 03/04/2024.
//

import SwiftUI
import HealthKit

struct HRView: View {
    @State private var heartRateSamples: [Double] = []
    @State private var latestHeartRate: Double? = nil
    @State private var lastCheckedTimestamp: Date? = nil
    
    let healthStore = HKHealthStore()

    var body: some View {
        VStack {
            ZStack {
                if let latestHeartRate = latestHeartRate {
                    AnimatedHeartView(currentBPM: latestHeartRate)
                } else {
                    AnimatedHeartView(currentBPM: 60)
                }
                VStack {
                    Text("Current")
                        .font(.headline)
                        .padding()
                        .offset(y: 110)
                    
                    Text("BPM")
                        .font(.largeTitle)
                        .padding()
                        .offset(y: 60)
                    
                    if let latestHeartRate = latestHeartRate {
                        Text("\(Int(latestHeartRate))")
                            .font(.largeTitle)
                            .padding()
                            .offset(y: -80)
                    } else {
                        Text("N/A")
                            .font(.largeTitle)
                            .padding()
                            .offset(y: -80)
                    }
                }
            }
            
            if let lastCheckedTimestamp = lastCheckedTimestamp {
                Text("Last checked by Apple Watch: \(formattedTimestamp(lastCheckedTimestamp))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top)
            }
            else {
                Text("Please allow us access to your health data")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top)
            }
            
        }
        .onAppear {
            fetchHeartRateData()
            setupHeartRateObserver()
        }
    }
    
    func fetchHeartRateData() {
        print("Fetching heart rate data...")
        
        guard let sampleType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            print("Heart rate sample type is no longer available in HealthKit")
            return
        }
        let startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            guard let samples = samples as? [HKQuantitySample], let sample = samples.first else {
                print("No samples available")
                return
            }
            print("Latest heart rate: \(sample.quantity.doubleValue(for: HKUnit(from: "count/min")))")

            DispatchQueue.main.async {
                self.latestHeartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                self.lastCheckedTimestamp = sample.startDate
            }
        }
        healthStore.execute(query)
    }

    private func formattedTimestamp(_ timestamp: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy 'at' HH:mm:ss"
        return formatter.string(from: timestamp)
    }
    
    func heartRateQuery(_ startDate: Date) -> HKQuery? {
        let quantityType = HKObjectType.quantityType(forIdentifier: .heartRate)
        let datePredicate = HKQuery.predicateForSamples(withStart: startDate, end: nil, options: .strictEndDate)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates:[datePredicate])
        
        let heartRateQuery = HKAnchoredObjectQuery(type: quantityType!, predicate: predicate, anchor: nil, limit: Int(HKObjectQueryNoLimit)) { (query, sampleObjects, deletedObjects, newAnchor, error) -> Void in
            // Handle new samples here
        }
        
        heartRateQuery.updateHandler = {(query, samples, deleteObjects, newAnchor, error) -> Void in
            guard let samples = samples as? [HKQuantitySample] else {return}
            DispatchQueue.main.async {
                guard let sample = samples.first else { return }
                let value = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                self.latestHeartRate = value
            }
        }
        
        return heartRateQuery
    }

    func setupHeartRateObserver() {
        let sampleType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let query = HKObserverQuery(sampleType: sampleType, predicate: nil) { (query: HKObserverQuery, completionHandler: @escaping () -> Void, error: Error?) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            if let heartRateQuery = self.heartRateQuery(Date()) {
                self.healthStore.execute(heartRateQuery)
            }
            completionHandler()
        }
        
        healthStore.execute(query)
    }
}

struct AnimatedHeartView: View {
    var currentBPM: Double
    
    @State private var isHeartBeating: Bool = false // Initialize with false
    
    // Define minimum and maximum animation durations
    private let minDuration: Double = 0.5
    private let maxDuration: Double = 2.0
    
    var body: some View {
        Image(systemName: "heart.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 200, height: 200)
            .foregroundColor(.red)
            .scaleEffect(isHeartBeating ? 1.2 : 1.0)
            .opacity(isHeartBeating ? 1.0 : 0.8) // Adjust opacity for pulsating effect
            .onAppear {
                startAnimationIfNeeded()
            }
            .onChange(of: currentBPM) { newBPM, _ in
                startAnimationIfNeeded()
            }
    }

    private func startAnimationIfNeeded() {
        // Clamp heart rate values to ensure they fall within a reasonable range
        let clampedBPM = min(max(currentBPM, 30), 200)
        
        // Calculate animation duration with adjustments
        let duration = max(minDuration, min(maxDuration, 60.0 / clampedBPM))
        
        if clampedBPM > 0 {
            // Start the animation only if the heart rate is greater than zero
            withAnimation(
                Animation.easeInOut(duration: duration)
                    .repeatForever(autoreverses: true) // Repeat the animation indefinitely
            ) {
                self.isHeartBeating = true
            }
        } else {
            // Stop the animation if the heart rate is zero
            self.isHeartBeating = false
        }
    }
}



struct previewHRView: PreviewProvider {
    static var previews: some View {
        HRView()
    }
}
