//
//  InTheZone
//
//  Created by Alex Brankin on 02/03/2024.
//
//
// The HeartTabsView in SwiftUI functions as a health data dashboard that dynamically switches between heart-related
// data and activity statistics using a segmented control. It leverages HealthKit to retrieve metrics such as
// average heart rate, VO2 max, heart rate variability, resting heart rate, step count, walking/running distance,
// active energy burned, and basal metabolic rate. Each data type is displayed within a grid of customizable boxes
// that can be expanded to show detailed views when tapped. 

import SwiftUI
import HealthKit

struct HeartTabsView: View {
    @StateObject private var healthKitManager = HealthKitManager()
    @ObservedObject private var userData = UserData()
    @State private var vo2Max: Double?
    @State private var hrv: Double?
    @State private var avghr: Double?
    @State private var restingHeartRate: Double?
    @State private var stepCount: Double?
    @State private var walkingRunningDistance: Double?
    @State private var activeEnergy: Double?
    @State private var bmr: Double?
    @State private var selectedTabIndex = 0
    
    var body: some View {
        VStack {
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
                    BoxedView(title: "Avg Heart Rate", value: formattedAvgHR(avghr))
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
        
        
        healthKitManager.fetchAverageHeartRateForDay { avghr, error in
            if let avghr = avghr {
                self.avghr = avghr
            } else if let error = error {
                print("Error fetching HeartRate: \(error.localizedDescription)")
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
    
    private func formattedAvgHR(_ value: Double?) -> String {
        guard let value = value else { return "N/A" }
        return "\(String(format: "%.0f", value)) bpm"
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
    @State private var isSheetPresented = false
    
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
            isSheetPresented = true
        }
        .sheet(isPresented: $isSheetPresented) {
            SheetView(title: title, value: value)
                .presentationDetents([.medium, .large])
        }
    }
}

struct InfoView: View {
    var title: String
    
    var body: some View {
        VStack {
            
            if title == "Avg Heart Rate" {
                MaxHeartRateInfoView()
                    .navigationTitle("Avg Heart Rate")
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
            if title == "Resting Energy" {
                RestingEnergyInfoView()
                    .navigationTitle("Resting Energy")
            }
            Spacer()
        }
    }
}


struct SheetView: View {
    var title: String
    var value: String

    @State private var goalSteps = UserDefaults.standard.integer(forKey: "goalSteps")
    @State private var isInfoViewPresented = false

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
                    .isDetailLink(false)
                }
                
                Divider()
                
                if title == "Step Count" {
                    StepCountView(totalSteps: Binding<Int>(
                        get: { Int(value) ?? 0 },
                        set: { _ in }
                    ), goalSteps: $goalSteps)
                } else if title == "Avg Heart Rate" {
                    AvgHRView()
                    
                } else if title == "VO2 Max" {
                    VO2MaxView()
                } else if title == "HRV" {
                    HRVView()
                } else if title == "Resting Heart Rate" {
                    RestingHRView()
                } else if title == "Distance Travelled" {
                    DistanceView()
                        .environmentObject(HealthKitManager())
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
                    let contentView = ContentView()
                    
                    window.rootViewController = UIHostingController(rootView: contentView)
                    window.rootViewController?.dismiss(animated: true, completion: nil)
                }
            }
            .padding()
        }
        .presentationDragIndicator(.visible)
        .onDisappear {
            UserDefaults.standard.set(goalSteps, forKey: "goalSteps")
        }
    }
}




struct HeartTabsView_Previews: PreviewProvider {
    static var previews: some View {
        HeartTabsView()
    }
}
