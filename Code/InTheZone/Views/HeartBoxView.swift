//
//  HeartBoxView.swift
//  InTheZone
//
//  Created by Alex Brankin on 08/04/2024.
//

import SwiftUI
import HealthKit

struct HeartTabsView: View {
    @StateObject private var healthKitManager = HealthKitManager()
    @State private var maxHeartRate: Double?
    @State private var vo2Max: Double?
    @State private var hrv: Double?
    @State private var restingHeartRate: Double?
    
    var body: some View {
        VStack {
            // Boxes
            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2)) {
                BoxedView(title: "Max Heart Rate", value: formattedValue(maxHeartRate))
                BoxedView(title: "VO2 Max", value: vo2Max != nil ? "\(vo2Max!)" : "N/A")
                BoxedView(title: "HRV", value: formattedHRV(hrv))
                BoxedView(title: "Resting Heart Rate", value: formattedValue(restingHeartRate))
            }
            .padding()
            .padding(.top, -30)
        }
        .onAppear {
            fetchHealthData()
        }
    }
    
    private func fetchHealthData() {
        // Fetch max heart rate
        healthKitManager.fetchMostRecentHeartRate { heartRate, _, error in
            if let heartRate = heartRate {
                maxHeartRate = heartRate
            } else if let error = error {
                print("Error fetching max heart rate: \(error.localizedDescription)")
            }
        }
        
        // Fetch VO2 max
        healthKitManager.fetchVO2Max { vo2Max, _, error in
            if let vo2Max = vo2Max {
                self.vo2Max = vo2Max
            } else if let error = error {
                print("Error fetching VO2 max: \(error.localizedDescription)")
            }
        }
        
        // Fetch HRV
        healthKitManager.fetchHeartRateVariability { hrv, _, error in
            if let hrv = hrv {
                self.hrv = hrv
            } else if let error = error {
                print("Error fetching HRV: \(error.localizedDescription)")
            }
        }
        
        // Fetch resting heart rate
        healthKitManager.fetchRestingHeartRate { restingHeartRate, _, error in
            if let restingHeartRate = restingHeartRate {
                self.restingHeartRate = restingHeartRate
            } else if let error = error {
                print("Error fetching resting heart rate: \(error.localizedDescription)")
            }
        }
    }
    
    private func formattedValue(_ value: Double?) -> String {
        guard let value = value else { return "N/A" }
        return String(format: "%.0f", value)
    }
    
    private func formattedHRV(_ value: Double?) -> String {
        guard let value = value else { return "N/A" }
        return "\(String(format: "%.0f", value)) ms"
    }
}


struct previewHeartTabsView: PreviewProvider {
    static var previews: some View {
        HeartTabsView()
    }
}
