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
    @ObservedObject private var userData = UserData()
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
                    BoxedView(title: "Max Heart Rate", value: "\(userData.maxHeartRate)")
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
        
        healthKitManager.fetchRestingHeartRateForToday { restingHeartRate, error in
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
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        
        if let formattedValue = formatter.string(from: NSNumber(value: value)) {
            return "\(formattedValue) kcal"
        } else {
            return "N/A"
        }
    }
    
    // Formatted distance value
    private func formattedDistance(_ value: Double?) -> String {
        guard let value = value else { return "N/A" }
        let distanceInKm = value / 1000.0 // Convert meters to kilometers
        return "\(String(format: "%.2f", distanceInKm)) km"
    }
    
    // Formatted Comma
    private func formattedComma(_ value: Double?) -> String {
        guard let value = value else { return "N/A" }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        
        if let formattedValue = formatter.string(from: NSNumber(value: value)) {
            return "\(formattedValue)"
        } else {
            return "N/A"
        }
    }
    
    // Formatted value
    private func formattedValue(_ value: Double?) -> String {
            guard let value = value else { return "N/A" }
            return "\(String(format: "%.0f", value))"
        }
    }




struct BoxedView: View {
    var title: String
    var value: String
    @State private var isSheetPresented = false // State to track sheet presentation
    
    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
            Text(value)
                .font(.subheadline)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
        .onTapGesture {
            isSheetPresented = true // Present the sheet when tapped
        }
        .sheet(isPresented: $isSheetPresented) {
            // Pass both title and value to DefaultSheetView
            SheetView(title: title, value: value)
                .presentationDetents([.medium]) // Specify the sheet to take up half the screen
        }
    }
}

struct InfoView: View {
    var title: String // Title for the information view
    
    var body: some View {
        VStack {
            
            if title == "Max Heart Rate" {
                MaxHeartRateInfoView()
                    .navigationTitle("Max Heart Rate")
            }
            if title == "VO2 Max" {
                VO2MaxInfoView()
                    .navigationTitle("VO2 Max")
            }
            if title == "HRV" {
                HRVInfoView()
                    .navigationTitle("HRV")
            }
            if title == "Resting Heart Rate" {
                RestingHeartRateInfoView()
                    .navigationTitle("Resting Heart Rate")
            }
            if title == "Step Count" {
                StepsInfoView()
                    .navigationTitle("Step Count")
            }
            if title == "Distance Travelled" {
                DistanceInfoView()
                    .navigationTitle("Distance Travelled")
            }
            if title == "Active Energy" {
                ActiveEnergyInfoView()
                    .navigationTitle("Active Energy")
            }
            if title == "BMR" {
                RestingEnergyView()
                    .navigationTitle("BMR")
            }
        }
    }
}


struct SheetView: View {
    var title: String
    var value: String

    @State private var goalSteps = UserDefaults.standard.integer(forKey: "goalSteps")
    @State private var isInfoViewPresented = false // State to control the visibility of the information view

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Spacer()
                    Text("\(title)")
                        .font(.headline)
                        .padding(.top, 20)
                        .padding(.leading, 30)
                    
                    Spacer()
                    NavigationLink(
                        destination: InfoView(title: title),
                        isActive: $isInfoViewPresented,
                        label: {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                                .padding(.top, 15)
                                .padding(.trailing,10)
                        }
                    )
                    .isDetailLink(false) // Disable automatic push behavior
                }
                
                Divider()
                
                if title == "Step Count" {
                    StepCountView(totalSteps: Binding<Int>(
                        get: { Int(value) ?? 0 },
                        set: { _ in }
                    ), goalSteps: $goalSteps) // Pass totalSteps as Binding
                } else if title == "Max Heart Rate" {
                    MaxHRView()
                    
                } else if title == "VO2 Max" {
                    VO2MaxView()
                } else if title == "HRV" {
                    HRVView()
                } else if title == "Resting Heart Rate" {
                    RestingHRView()
                } else if title == "Distance Travelled" {
                    DistanceView()
                } else if title == "Active Energy" {
                    ActiveEnergyView()
                } else if title == "Resting Energy" {
                    RestingEnergyView()
                }
            }
            Spacer()
            Button("Close") {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    window.rootViewController?.dismiss(animated: true, completion: nil)
                }
            }
            .padding()
        }
        .presentationDragIndicator(.visible)
        .onDisappear {
            // Save the updated goalSteps value to UserDefaults when the view disappears
            UserDefaults.standard.set(goalSteps, forKey: "goalSteps")
        }
    }
}




struct HeartTabsView_Previews: PreviewProvider {
    static var previews: some View {
        HeartTabsView()
    }
}
