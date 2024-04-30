//
//  InTheZone
//
//  Created by Alex Brankin on 02/03/2024.
//

import SwiftUI
import Charts
import HealthKit

struct HRVView: View {
    @State private var selectedRange: String = "30D"
    let dateRanges = ["7D", "30D", "365D"]
    @State private var healthData: [HRVChartData] = []
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
                                y: .value("HRV", data.value)
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
        
        let sampleType = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
        
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
                
                let value = average.doubleValue(for: HKUnit.secondUnit(with: .milli))
                healthData.append(HRVChartData(id: i, date: startDate, value: value))
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


struct HRVChartData {
    let id: Int
    let date: Date
    let value: Double
}


struct HRVInfoView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
                
            
            Text("Heart rate variability (HRV) is the variation in time between each heartbeat. It's considered an indicator of the autonomic nervous system's activity and can reflect the body's ability to respond to stress.")
                .font(.body)
                .foregroundColor(.secondary)
            
            Divider()
            
            Text("Factors Affecting HRV:")
                .font(.headline)
            
            Text("1. Stress: Higher stress levels can lead to decreased HRV.")
                .font(.body)
                .foregroundColor(.secondary)
            
            Text("2. Exercise: Regular exercise can improve HRV.")
                .font(.body)
                .foregroundColor(.secondary)
            
            Text("3. Sleep: Quality sleep is associated with higher HRV.")
                .font(.body)
                .foregroundColor(.secondary)
            
            Divider()
            
            Text("HRV Monitoring:")
                .font(.headline)
            
            Text("HRV can be monitored using specialized devices or certain fitness trackers. Tracking changes in HRV over time may provide insights into overall health and fitness.")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

struct HRVInfoView_Previews: PreviewProvider {
    static var previews: some View {
        HRVInfoView()
    }
}



#Preview {
    HRVView()
}
