//
//  InTheZone
//
//  Created by Alex Brankin on 02/03/2024.
//
// The DistanceView SwiftUI code displays a chart of cumulative distance traveled over a selected time range using
// HealthKit data. It includes a segmented picker for time range selection and fetches data asynchronously.
// Additionally, the DistanceInfoView provides complementary information on tracking distance using GPS devices and
// fitness trackers.

import SwiftUI
import Charts
import HealthKit

struct DistanceView: View {
    @State private var selectedRange: String = "30D"
    let dateRanges = ["7D", "30D", "365D"]
    @State private var healthData: [DistChartData] = []
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
                            BarMark(
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
        
        let sampleType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
        
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
            
            let query = HKStatisticsQuery(quantityType: sampleType, quantitySamplePredicate: predicate, options: .cumulativeSum) { query, result, error in
                // Enter the semaphore
                semaphore.signal()
                
                guard let result = result, let sum = result.sumQuantity() else {
                    if let error = error {
                        print("Error fetching Distance data for chart: \(error.localizedDescription)")
                    }
                    // If data is not available for this day, move to the next day
                    startDate = nextDate
                    return
                }
                
                let distanceUnit = HKUnit.mile() // This will give you a unit in kilometers
                let value = sum.doubleValue(for: distanceUnit)

                healthData.append(DistChartData(id: i, date: startDate, value: value))
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

struct DistChartData {
    let id: Int
    let date: Date
    let value: Double
}


struct DistanceInfoView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
                
            
            Text("Distance travelled is a measure of the total distance covered by an individual over a certain period. It's often used to track outdoor activities such as walking, running, or cycling.")
                .font(.body)
                .foregroundColor(.secondary)
            
            Divider()
            
            Text("Tracking Distance:")
                .font(.headline)
            
            Text("1. GPS Devices: GPS-enabled devices can accurately track distance travelled during outdoor activities.")
                .font(.body)
                .foregroundColor(.secondary)
            
            Text("2. Fitness Trackers: Many fitness trackers can estimate distance based on step count and stride length.")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

struct DistanceInfoView_Previews: PreviewProvider {
    static var previews: some View {
        DistanceInfoView()
    }
}


#Preview {
    DistanceView()
        .environmentObject(HealthKitManager())
}
