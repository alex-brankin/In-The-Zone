//
//  InTheZone
//
//  Created by Alex Brankin on 02/03/2024.
//

import SwiftUI
import Charts
import HealthKit

struct VO2MaxView: View {
    @State private var selectedRange: String = "365D"
    let dateRanges = ["7D", "30D", "365D"]
    @State private var healthData: [VO2ChartData] = []
    private let healthStore = HKHealthStore()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Picker("Select Range", selection: $selectedRange) {
                        ForEach(dateRanges, id: \.self) { range in
                            Text(range)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    
                    Chart {
                        ForEach(healthData, id: \.id) { data in
                            LineMark(
                                x: .value("Date", data.date, unit: .day),
                                y: .value("BPM", data.value)
                            )
                            .foregroundStyle(.red)
                        }
                    }
                    .frame(height: 200)
                    .padding(.horizontal)
                    
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                fetchHealthData()
            }
            .onChange(of: selectedRange) { _ in
                fetchHealthData() // Call fetchHealthData() when selectedRange changes
            }
        }
    }
    
    
    func fetchHealthData() {
        let calendar = Calendar.current
        let now = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
        let endDate = calendar.startOfDay(for: yesterday)
        
        guard let sampleType = HKObjectType.quantityType(forIdentifier: .vo2Max) else {
            print("VO2Max data type is not available.")
            return
        }
        
        // Calculate start date based on selected range
        var startDate: Date
        switch selectedRange {
        case "7D":
            startDate = calendar.date(byAdding: .day, value: -6, to: endDate)!
        case "30D":
            startDate = calendar.date(byAdding: .day, value: -29, to: endDate)!
        case "365D":
            startDate = calendar.date(byAdding: .day, value: -364, to: endDate)!
        default:
            startDate = calendar.date(byAdding: .day, value: -6, to: endDate)!
        }
        
        // Create a semaphore to make the query synchronous
        let semaphore = DispatchSemaphore(value: 0)
        
        // Clear previous health data
        healthData = []
        let kgmin = HKUnit.gramUnit(with: .kilo).unitMultiplied(by: .minute())
        let mL = HKUnit.literUnit(with: .milli)
        let VO₂Unit = mL.unitDivided(by: kgmin)
        var prevDate = startDate
        print("startDate : \(startDate)")
        for i in 0...0 { //Int(selectedRange.dropLast())! {
            print("going through loop : \(i)")
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictEndDate)
            
            let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
                guard let samples = samples as? [HKQuantitySample] else {
                    if let error = error {
                        print("Error fetching VO2Max data: \(error.localizedDescription)")
                    }
                    semaphore.signal()
                    return
                }
                
                var sampleIndex = 0
                for sample in samples {
                    let value = sample.quantity.doubleValue(for: VO₂Unit)
                    let date = sample.startDate
                    self.healthData.append(VO2ChartData(id: sampleIndex, date: date, value: value))
                    print("Index :\(i) Date: \(date), VO2Max: \(value) mL/kg/min")
                    sampleIndex = sampleIndex + 1
                }
                
                // Signal semaphore after processing samples
                semaphore.signal()
            }
            
            // Execute the query
            healthStore.execute(query)
            
            // Wait for the semaphore
            semaphore.wait()
        }
    }
}

struct VO2ChartData {
    let id: Int
    let date: Date
    let value: Double
}

struct VO2MaxInfoView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
                
            
            Text("Resting heart rate (RHR) is the number of heartbeats per minute when the body is at rest. It's a measure of cardiovascular fitness and can be an indicator of overall health.")
                .font(.body)
                .foregroundColor(.secondary)
            
            Divider()
            
            Text("Factors Affecting RHR:")
                .font(.headline)
            
            Text("1. Fitness Level: Higher fitness levels are associated with lower RHR.")
                .font(.body)
                .foregroundColor(.secondary)
            
            Text("2. Age: RHR tends to increase with age.")
                .font(.body)
                .foregroundColor(.secondary)
            
            Text("3. Stress and Health Conditions: Stress and certain health conditions can elevate RHR.")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

struct VO2MaxInfoView_Previews: PreviewProvider {
    static var previews: some View {
        RestingHeartRateInfoView()
    }
}
