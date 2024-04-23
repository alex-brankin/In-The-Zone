//
//  HRVView.swift
//  InTheZone
//
//  Created by Alex Brankin on 17/04/2024.
//

import SwiftUI
import Charts
import HealthKit

struct HRVView: View {
    @State private var selectedRange: String = "7D"
    let dateRanges = ["7D", "30D", "1Y"]
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
        let sampleType = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
        
        // Start fetching data from 7 days ago
        guard var startDate = calendar.date(byAdding: .day, value: -7, to: endDate) else { return }
        
        for i in 0..<7 {
            // Move to the next day
            let nextDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
            
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: nextDate, options: .strictEndDate)
            
            let query = HKStatisticsQuery(quantityType: sampleType, quantitySamplePredicate: predicate, options: .discreteAverage) { query, result, error in
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
