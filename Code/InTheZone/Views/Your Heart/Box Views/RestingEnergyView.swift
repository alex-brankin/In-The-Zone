//
//  InTheZone
//
//  Created by Alex Brankin on 02/03/2024.
//

import SwiftUI
import Charts
import HealthKit

struct RestingEnergyView: View {
    @State private var selectedRange: String = "30D"
    let dateRanges = ["7D", "30D", "365D"]
    @State private var healthData: [RestingChartData] = []
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
        
        let sampleType = HKObjectType.quantityType(forIdentifier: .basalEnergyBurned)!
        
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
                        print("Error fetching Resting Energy data for chart: \(error.localizedDescription)")
                    }
                    // If data is not available for this day, move to the next day
                    startDate = nextDate
                    return
                }
                
                let value = sum.doubleValue(for: HKUnit.kilocalorie())

                healthData.append(RestingChartData(id: i, date: startDate, value: value))
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

struct RestingChartData {
    let id: Int
    let date: Date
    let value: Double
}



struct RestingEnergyInfoView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
                
            
            Text("Resting energy expenditure (REE) is the amount of energy expended by the body at rest to maintain essential physiological functions such as breathing, circulation, and cellular activity. It's often expressed in kilocalories (kcal) per day.")
                .font(.body)
                .foregroundColor(.secondary)
            
            Divider()
            
            Text("Factors Affecting Resting Energy:")
                .font(.headline)
            
            Text("1. Basal Metabolic Rate (BMR): Resting energy expenditure is closely related to BMR, which is influenced by factors such as age, sex, weight, and body composition.")
                .font(.body)
                .foregroundColor(.secondary)
            
            Text("2. Muscle Mass: Individuals with higher muscle mass typically have higher resting energy expenditure.")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

struct RestingEnergyInfoView_Previews: PreviewProvider {
    static var previews: some View {
        RestingEnergyInfoView()
    }
}


#Preview {
    RestingEnergyView()
}
