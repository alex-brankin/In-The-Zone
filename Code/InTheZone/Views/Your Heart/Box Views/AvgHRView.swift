//
//  InTheZone
//
//  Created by Alex Brankin on 02/03/2024.
//

import SwiftUI
import HealthKit
import Charts

struct AvgHRView: View {
    @State private var selectedRange: String = "30D"
    let dateRanges = ["7D", "30D", "365D"]
    @State private var healthData: [HRChartData] = []
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
                                y: .value("Heart Rate", data.value)
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
        
        let sampleType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        
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
                        print("Error fetching HR data for chart: \(error.localizedDescription)")
                    }
                    // If data is not available for this day, move to the next day
                    startDate = nextDate
                    return
                }
                
                let value = average.doubleValue(for: HKUnit(from: "count/min"))
                healthData.append(HRChartData(id: i, date: startDate, value: value))
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






struct HRChartData {
    let id: Int
    let date: Date
    let value: Double
}

struct MaxHeartRateInfoView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
                
            
            Text("Your maximum heart rate is the highest number of heartbeats per minute (bpm) that your body can reach during physical activity.")
                .font(.body)
                .foregroundColor(.secondary)
            
            Divider()
            
            Text("Formula for Estimating Maximum Heart Rate:")
                .font(.headline)
            
            Text("220 - your age")
                .font(.subheadline)
                .foregroundColor(.red)
                .padding(.bottom, 10)
            
            Divider()
            
            Text("It's important to note that this is a general estimation and may not be accurate for everyone. Factors such as fitness level, genetics, and overall health can influence your maximum heart rate.")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

struct MaxHeartRateInfoView_Previews: PreviewProvider {
    static var previews: some View {
        MaxHeartRateInfoView()
    }
}




struct AvgHRView_Previews: PreviewProvider {
    static var previews: some View {
        AvgHRView()
    }
}
