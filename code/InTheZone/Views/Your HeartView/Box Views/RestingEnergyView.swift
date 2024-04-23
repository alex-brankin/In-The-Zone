//
//  RestingEnergyView.swift
//  InTheZone
//
//  Created by Alex Brankin on 17/04/2024.
//

import SwiftUI
import Charts
import HealthKit

struct RestingEnergyView: View {
    @State private var selectedRange: String = "7D"
    let dateRanges = ["7D", "30D", "1Y"]
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
                            LineMark(
                                x: .value("Date", data.date, unit: .day),
                                y: .value("Resting Energy", data.value)
                            )
                            .foregroundStyle(.blue)
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
        }
        
    }
    
    func fetchHealthData() {
        let calendar = Calendar.current
        let endDate = Date()
        let sampleType = HKObjectType.quantityType(forIdentifier: .basalEnergyBurned)!
        
        // Start fetching data from 7 days ago
        guard var startDate = calendar.date(byAdding: .day, value: -7, to: endDate) else { return }
        
        for i in 0..<7 {
            // Move to the next day
            let nextDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
            
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: nextDate, options: .strictEndDate)
            
            let query = HKStatisticsQuery(quantityType: sampleType, quantitySamplePredicate: predicate, options: .cumulativeSum) { query, result, error in
                guard let result = result else {
                    if let error = error {
                        print("Error fetching resting energy data for chart: \(error.localizedDescription)")
                    }
                    // If data is not available for this day, move to the next day
                    startDate = nextDate
                    return
                }
                
                let value = result.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
                healthData.append(RestingChartData(id: i, date: startDate, value: value))
                
                // Move to the next day
                startDate = nextDate
                
                // Once all data points are fetched, sort them by date
                if i == 6 {
                    healthData.sort { $0.date < $1.date }
                }
            }
            
            healthStore.execute(query)
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
