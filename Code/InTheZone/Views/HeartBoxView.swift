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
    @State private var maxHeartRate: Double? = 195
    @State private var vo2Max: Double?
    @State private var hrv: Double?
    @State private var restingHeartRate: Double?
    @State private var stepCount: Double?
    @State private var walkingRunningDistance: Double?
    @State private var activeEnergy: Double?
    @State private var bmr: Double?
    @State private var selectedTabIndex = 0 // Added state to track selected tab index
    
    var body: some View {
        VStack {
            // Segment control to switch between heart and activity data
            Picker(selection: $selectedTabIndex, label: Text("")) {
                Text("Heart Data").tag(0)
                Text("Activity Data").tag(1)

            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.bottom, 10)
            .padding(.leading)
            .padding(.trailing)
            
            // Boxes
            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2)) {
                if selectedTabIndex == 0 {
                    BoxedView(title: "Max Heart Rate", value: formattedValue(maxHeartRate))
                    BoxedView(title: "VO2 Max", value: vo2Max != nil ? "\(vo2Max!)" : "N/A")
                    BoxedView(title: "HRV", value: formattedHRV(hrv))
                    BoxedView(title: "Resting Heart Rate", value: formattedValue(restingHeartRate))
                } else {
                    BoxedView(title: "Step Count", value: formattedValue(stepCount))
                    BoxedView(title: "Distance Travelled", value: formattedDistance(walkingRunningDistance))
                    BoxedView(title: "Active Energy", value: formattedKcal(activeEnergy))
                    BoxedView(title: "Resting Energy", value: formattedKcal(bmr))
                }

            }
            .padding()
            .padding(.top, -20)
            .padding(.bottom, -20)
        }
        .onAppear {
            fetchHealthData()
            }
        .onChange(of: selectedTabIndex) {
            fetchHealthData()
        }




        }

    
    // Fetches health data based on selected tab
    private func fetchHealthData() {
        if selectedTabIndex == 0 {
            fetchHeartData()
        } else {
            fetchActivityData()
        }
    }
    
    // Fetches heart-related data
    private func fetchHeartData() {
        healthKitManager.fetchVO2Max { vo2Max, _, error in
            if let vo2Max = vo2Max {
                self.vo2Max = vo2Max
            } else if let error = error {
                print("Error fetching VO2 max: \(error.localizedDescription)")
            }
        }
        
        healthKitManager.fetchHeartRateVariability { hrv, _, error in
            if let hrv = hrv {
                self.hrv = hrv
            } else if let error = error {
                print("Error fetching HRV: \(error.localizedDescription)")
            }
        }
        
        healthKitManager.fetchRestingHeartRate { restingHeartRate, _, error in
            if let restingHeartRate = restingHeartRate {
                self.restingHeartRate = restingHeartRate
            } else if let error = error {
                print("Error fetching resting heart rate: \(error.localizedDescription)")
            }
        }
    }
    
    // Fetches activity-related data
    private func fetchActivityData() {
        healthKitManager.fetchStepCount { stepCount, _, error in
            if let stepCount = stepCount {
                self.stepCount = stepCount
            } else if let error = error {
                print("Error fetching step count: \(error.localizedDescription)")
            }
        }
        
        healthKitManager.fetchWalkingRunningDistance { distance, error in
            if let distance = distance {
                self.walkingRunningDistance = distance
            } else if let error = error {
                print("Error fetching walking+running distance: \(error.localizedDescription)")
            }
        }
        
        healthKitManager.fetchActiveEnergy { activeEnergy, error in
            if let activeEnergy = activeEnergy {
                self.activeEnergy = activeEnergy
            } else if let error = error {
                print("Error fetching active energy: \(error.localizedDescription)")
            }
        }
        
        healthKitManager.fetchBMR { bmr, error in
            if let bmr = bmr {
                self.bmr = bmr
            } else if let error = error {
                print("Error fetching BMR: \(error.localizedDescription)")
            }
        }
    }
    
    // Formatted value functions
    
    // HRV formatted value
    private func formattedHRV(_ value: Double?) -> String {
        guard let value = value else { return "N/A" }
        return "\(String(format: "%.0f", value)) ms"
    }
    
    // kcal formatted values
    private func formattedKcal(_ value: Double?) -> String {
        guard let value = value else { return "N/A" }
        return "\(String(format: "%.0f", value)) kcal"
    }
    
    // Formatted distance value
    private func formattedDistance(_ value: Double?) -> String {
        guard let value = value else { return "N/A" }
        let distanceInKm = value / 1000.0 // Convert meters to kilometers
        return "\(String(format: "%.2f", distanceInKm)) km"
    }

    
    // Formatted value
    private func formattedValue(_ value: Double?) -> String {
        guard let value = value else { return "N/A" }
        return String(format: "%.0f", value)
    }
}

struct BoxedView: View {
    var title: String
    var value: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
            Text(value)
                .font(.subheadline)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Set a fixed size for each box
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
    }
}


struct HeartTabsView_Previews: PreviewProvider {
    static var previews: some View {
        HeartTabsView()
    }
}
