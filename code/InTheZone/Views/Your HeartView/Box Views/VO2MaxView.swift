//
//  VO2MaxView.swift
//  InTheZone
//
//  Created by Alex Brankin on 17/04/2024.
//

import SwiftUI
import HealthKit
import Charts

struct VO2MaxView: View {
    @State private var selectedRange: String = "7D"
    let dateRanges = ["7D", "30D", "1Y"]
    @State private var healthData: [VO2MaxChart] = []
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
                                y: .value("VO2 Max", data.value)
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
        let sampleType = HKObjectType.quantityType(forIdentifier: .vo2Max)!
        
        // Start fetching data from 7 days ago
        guard var startDate = calendar.date(byAdding: .day, value: -7, to: endDate) else { return }
        
        for i in 0..<7 {
            // Move to the next day
            let nextDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
            
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: nextDate, options: .strictEndDate)
            
            let query = HKStatisticsQuery(quantityType: sampleType, quantitySamplePredicate: predicate, options: .discreteAverage) { query, result, error in
                guard let result = result, let average = result.averageQuantity() else {
                    if let error = error {
                        print("Error fetching VO2 max data for chart: \(error.localizedDescription)")
                    }
                    // If data is not available for this day, move to the next day
                    startDate = nextDate
                    return
                }
                
                let value = average.doubleValue(for: HKUnit(from: "ml/min/kg"))
                healthData.append(VO2MaxChart(id: i, date: startDate, value: value))
                
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

struct VO2MaxChart {
    let id: Int
    let date: Date
    let value: Double
}



struct VO2MaxInfoView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
                
            
            Text("VO2 max, or maximal oxygen consumption, is the maximum rate of oxygen consumption measured during incremental exercise. It reflects the aerobic physical fitness of an individual and is an important indicator of cardiovascular health.")
                .font(.body)
                .foregroundColor(.secondary)
            
            Divider()
            
            Text("Factors Affecting VO2 Max:")
                .font(.headline)
            
            Text("1. Genetics: Genetics play a significant role in determining an individual's VO2 max.")
                .font(.body)
                .foregroundColor(.secondary)
            
            Text("2. Age: VO2 max tends to decrease with age, particularly after reaching middle age.")
                .font(.body)
                .foregroundColor(.secondary)
            
            Text("3. Training: Regular physical activity and cardiovascular exercise can improve VO2 max over time.")
                .font(.body)
                .foregroundColor(.secondary)
            
        }
        .padding()
    }
}

struct VO2MaxInfoView_Previews: PreviewProvider {
    static var previews: some View {
        VO2MaxInfoView()
    }
}


struct VO2MaxView_Previews: PreviewProvider {
    static var previews: some View {
        VO2MaxView()
    }
}
