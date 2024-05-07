//
//  InTheZone
//
//  Created by Alex Brankin on 02/03/2024.
//
// The RestingHRView in SwiftUI allows users to explore their resting heart rate (RHR) data from HealthKit,
// providing interactive charts to visualize changes over time based on selected date ranges. This view uses a
// segmented picker to choose between different time intervals and plots the data on a line chart, updating
// dynamically with changes in the selected time frame. The view fetches RHR data synchronously using semaphores to
// manage asynchronous HealthKit queries efficiently. Additionally, an informative section explains the significance
// of RHR and the factors affecting it, enriching user understanding of cardiovascular fitness and health.

import SwiftUI
import Charts
import HealthKit

struct RestingHRView: View {
    @State private var selectedRange: String = "30D"
    let dateRanges = ["7D", "30D", "365D"]
    @State private var healthData: [RHRChartData] = []
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
        
        let sampleType = HKObjectType.quantityType(forIdentifier: .restingHeartRate)!
        
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
        
        var prevDate = startDate
        print("startDate : \(startDate)")
        for i in 0..<Int(selectedRange.dropLast())! {
            print("going through loop : \(i)")
            // Move to the next day
            let nextDate = calendar.date(byAdding: .day, value: 1, to: prevDate)!
            prevDate = nextDate
            print("nextDate : \(nextDate)")
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: nextDate, options: .strictEndDate)
            
            let query = HKStatisticsQuery(quantityType: sampleType, quantitySamplePredicate: predicate, options: .discreteAverage) { query, result, error in
                // Enter the semaphore
                semaphore.signal()
                
                guard let result = result, let average = result.averageQuantity() else {
                    if let error = error {
                        print("Error fetching HRV data for chart: \(error.localizedDescription)")
                    }
                    // If data is not available for this day, move to the next day
                    startDate = nextDate
                    return
                }
                
                let value = average.doubleValue(for: HKUnit(from: "count/min"))
                healthData.append(RHRChartData(id: i, date: startDate, value: value))
                print("Start Date : \(startDate)  Value : \(value)")
                // Move to the next day
                startDate = nextDate
            }
            
            // Execute the query
            healthStore.execute(query)
            
            // Wait for the semaphore
            semaphore.wait()
        }
    }
}

struct RHRChartData {
    let id: Int
    let date: Date
    let value: Double
}

struct RestingHeartRateInfoView: View {
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

struct RestingHeartRateInfoView_Previews: PreviewProvider {
    static var previews: some View {
        RestingHeartRateInfoView()
    }
}
