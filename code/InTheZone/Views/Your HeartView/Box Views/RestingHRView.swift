//
//  RestingHRView.swift
//  InTheZone
//
//  Created by Alex Brankin on 17/04/2024.
//

import SwiftUI
import HealthKit
import Charts

struct RestingHRView: View {
    @State private var selectedRange: String = "7D"
    let dateRanges = ["7D", "30D", "1Y"]
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
                                y: .value("Resting Heart Rate", data.value)
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
            .onChange(of: selectedRange) { _ in
                fetchHealthData()
            }
        }
    }
    
    func fetchHealthData() {
        let endDate = Date()
        var startDate = Date()
        
        switch selectedRange {
        case "1D":
            startDate = endDate.addingTimeInterval(-86400)
        case "7D":
            startDate = endDate.addingTimeInterval(-86400 * 7)
        case "30D":
            startDate = endDate.addingTimeInterval(-86400 * 30)
        case "1Y":
            startDate = endDate.addingTimeInterval(-86400 * 365)
        default:
            break
        }
        
        let sampleType = HKObjectType.quantityType(forIdentifier: .restingHeartRate)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictEndDate)
        
        let query = HKStatisticsQuery(quantityType: sampleType, quantitySamplePredicate: predicate, options: .discreteAverage) { query, result, error in
            guard let result = result, let average = result.averageQuantity() else {
                if let error = error {
                    print("Error fetching resting heart rate data: \(error.localizedDescription)")
                }
                return
            }
            
            let value = average.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
            healthData.append(RHRChartData(id: healthData.count, date: endDate, value: value))
            print("Resting Heart Rate: \(value)")
            print(healthData)
        }
        
        healthStore.execute(query)
    }
}

struct RHRChartData {
    let id: Int
    let date: Date
    let value: Double
}

struct RestingHeartRateView_Previews: PreviewProvider {
    static var previews: some View {
        RestingHRView()
    }
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
