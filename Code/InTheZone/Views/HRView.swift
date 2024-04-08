//
//  HRView.swift
//  InTheZone
//
//  Created by Alex Brankin on 03/04/2024.
//

import SwiftUI
import HealthKit

struct AnimatedHeartView: View {
    var currentBPM: Int // Property to receive the current BPM
    
    @State private var isHeartBeating = false // State variable to control the animation
    
    var body: some View {
        Image(systemName: "heart.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 200, height: 200)
            .foregroundColor(.red)
            .scaleEffect(isHeartBeating ? 1.2 : 1.0)
            .animation(.easeInOut(duration: 60.0 / Double(currentBPM)), value: currentBPM) // Apply animation based on BPM
            .onAppear {
                // Start animation when heart rate data is fetched
                if currentBPM > 0 {
                    self.isHeartBeating = true
                }
            }
    }
}

struct HRView: View {
    @State private var heartRateSamples: [Double] = []
    @State private var latestHeartRate: Double? = nil
    @State private var lastCheckedTimestamp: Date? = nil // New state variable to hold the timestamp
    @State private var currentBPM: Int = 60 // Define currentBPM as a state variable
    
    let healthStore = HKHealthStore()

    var body: some View {
        VStack {
            ZStack {
                AnimatedHeartView(currentBPM: currentBPM) // Pass currentBPM directly
                    .padding()
                  
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
                        Text("\(Int(latestHeartRate))") // Show latestHeartRate if available
                            .font(.largeTitle)
                            .padding()
                            .offset(y: -80)
                    } else {
                        Text("N/A") // Show "N/A" if latestHeartRate is nil
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
                    .padding(.bottom)
            }
            
        }
        .onAppear {
            fetchHeartRateData() // Fetch initially
        }
    }
    

    func fetchHeartRateData() {
        print("Fetching heart rate data...") // Print console message
        
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
                self.lastCheckedTimestamp = sample.startDate // Set the last checked timestamp
                // Update currentBPM when heart rate data is fetched
                self.currentBPM = Int(sample.quantity.doubleValue(for: HKUnit(from: "count/min")))
            }
        }
        healthStore.execute(query)
    }

    // Function to format timestamp
    private func formattedTimestamp(_ timestamp: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy 'at' HH:mm:ss"
        return formatter.string(from: timestamp)
    }
}

struct LineChart: View {
    var dataPoints: [Double]

    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(dataPoints.indices, id: \.self) { index in
                    Text(String(format: "%.0f", dataPoints[index]))
                        .padding(.horizontal, 4)
                }
            }
        }
    }
}


struct HRView_Previews: PreviewProvider {
    static var previews: some View {
        HRView()
    }
}
