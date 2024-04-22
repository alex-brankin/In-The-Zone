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
    @State private var restingHeartRates: [Double] = []
    @State private var dates: [Date]?
    @State private var error: Error?
    let healthManager = HealthKitManager()
    
    var body: some View {
        VStack {
            if !healthManager.oneMonthChartData.isEmpty {
                Chart {
                    ForEach(healthManager.oneMonthChartData) { daily in
                        LineMark(
                            x: .value(daily.date.formatted(), daily.date, unit: .day),
                            y: .value("Heart Rate", daily.RestingHeardRate))
                    }
                }
                .padding()
            }
        }
        .onAppear {
            fetchRestingHeartRates()
        }
    }
    
    func fetchRestingHeartRates() {
        healthManager.fetchRestingHeartRate(forLastDays: 7) { restingHeartRates, dates, error in
            if let error = error {
                self.error = error
            } else if let restingHeartRates = restingHeartRates {
                self.restingHeartRates = restingHeartRates
                self.dates = dates
            }
        }
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
        .background(Color.white)
        .padding()
    }
}

struct RestingHeartRateInfoView_Previews: PreviewProvider {
    static var previews: some View {
        RestingHeartRateInfoView()
    }
}


struct RestingHeartRateChartView_Previews: PreviewProvider {
    static var previews: some View {
        RestingHRView()
    }
}
