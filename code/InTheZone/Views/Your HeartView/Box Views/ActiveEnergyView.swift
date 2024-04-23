//
//  ActiveEnergyView.swift
//  InTheZone
//
//  Created by Alex Brankin on 17/04/2024.
//

import SwiftUI
import Charts
import HealthKit

struct ActiveEnergyView: View {
    @State private var selectedRange: String = "7D"
    let dateRanges = ["7D", "30D", "1Y"]
    @State private var healthData: [ActiveChartData] = []
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
                                y: .value("Active Energy", data.value)
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
        let sampleType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        
        // Start fetching data from 7 days ago
        guard var startDate = calendar.date(byAdding: .day, value: -7, to: endDate) else { return }
        
        for i in 0..<7 {
            // Move to the next day
            let nextDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
            
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: nextDate, options: .strictEndDate)
            
            let query = HKStatisticsQuery(quantityType: sampleType, quantitySamplePredicate: predicate, options: .cumulativeSum) { query, result, error in
                guard let result = result else {
                    if let error = error {
                        print("Error fetching active energy data for chart: \(error.localizedDescription)")
                    }
                    // If data is not available for this day, move to the next day
                    startDate = nextDate
                    return
                }
                
                let value = result.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
                healthData.append(ActiveChartData(id: i, date: startDate, value: value))
                
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

struct ActiveChartData {
    let id: Int
    let date: Date
    let value: Double
}


struct ActiveEnergyInfoView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
                
            
            Text("Active energy represents the amount of energy expended during physical activity. It's often measured in kilocalories (kcal) or kilojoules (kJ) and can provide insights into the intensity and duration of exercise.")
                .font(.body)
                .foregroundColor(.secondary)
            
            Divider()
            
            Text("Measuring Active Energy:")
                .font(.headline)
            
            Text("1. Fitness Trackers: Many fitness trackers can estimate active energy expenditure based on activity type, duration, and heart rate.")
                .font(.body)
                .foregroundColor(.secondary)
            
            Text("2. Smartwatches: Smartwatches with built-in fitness features often track active energy during workouts.")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

struct ActiveEnergyInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ActiveEnergyInfoView()
    }
}


#Preview {
    ActiveEnergyView()
}
