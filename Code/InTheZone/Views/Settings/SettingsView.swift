//
//  InTheZone
//
//  Created by Alex Brankin on 02/03/2024.
//
// The SettingsView in SwiftUI manages user preferences for notifications, heart rate zones, and step goals. It
// incorporates SwiftUI's @AppStorage for persistent storage of user settings, like notifications enablement and
// heart rate parameters, which adjust through interactive sliders for visual customization. The view also offers a
// reset functionality to clear all user settings, leveraging user defaults. Additional UI components, such as
// toggles for notifications and sliders for setting heart rate zones, enhance user interaction, with changes being
// committed to UserDefaults and visual feedback provided through color-coded heart rate zones.

import SwiftUI

struct SettingsView: View {
    @StateObject private var profileViewModel = ProfileViewModel()
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @State private var stepGoalText = "10000"
    @State private var isStepGoalValid = true
    @StateObject private var settingsManager = SettingsManager()
    @State private var isErrorOccurred = false
    @State private var errorMessage = ""
    @State private var isMaxHeartRateValid = true
    @AppStorage("maxHeartRate") private var maxHeartRateSetting: String = ""
    @State private var heartRateZones: [Int] = [100, 120, 140, 160, 220] // Default values
    @State private var showResetAlert = false
    @AppStorage("zone1Min") private var zone1Min = ""
    @AppStorage("zone1Max") private var zone1Max = ""
    @AppStorage("zone2Min") private var zone2Min = ""
    @AppStorage("zone2Max") private var zone2Max = ""
    @AppStorage("zone3Min") private var zone3Min = ""
    @AppStorage("zone3Max") private var zone3Max = ""
    @AppStorage("zone4Min") private var zone4Min = ""
    @AppStorage("zone4Max") private var zone4Max = ""
    @AppStorage("zone5Min") private var zone5Min = ""
    @AppStorage("zone5Max") private var zone5Max = ""
    
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Heart Rate Zones")) {
                    VStack(spacing: -10) { // Adjust spacing between VStack elements
                        ForEach(0..<5) { index in
                            VStack {
                                Text("Zone \(index + 1) Heart Rate: \(zoneRangeText(for: index))")
                                    .padding(.top, 15)
                                Slider(value: Binding<Double>(
                                    get: {
                                        if index == heartRateZones.count - 1 {
                                            return Double(heartRateZones[index])
                                        } else {
                                            return Double(heartRateZones[index])
                                        }
                                    },
                                    set: { newValue in
                                        if index == 0 || (index < heartRateZones.count - 1 && Int(newValue) >= heartRateZones[index - 1] + 2 && Int(newValue) < heartRateZones[index + 1]) {
                                            heartRateZones[index] = Int(newValue)
                                            
                                        } else if index == heartRateZones.count - 1 && Int(newValue) > heartRateZones[index - 1] + 2 {
                                            heartRateZones[index] = Int(newValue)
                                            zone5Max = "\(Int(newValue))"
                                        }
                            }
                                ), in: 40...220, step: 1.0)
                                .padding(.horizontal, -10) // Add negative horizontal padding
                                .padding(.bottom, -5) // Add negative bottom padding
                                .accentColor(zoneColor(for: index))
                            }
                            .listRowInsets(EdgeInsets()) // Set padding to zero
                        }
                    }
                }
                
                Button("Reset Profile") {
                                    showResetAlert = true
                                }
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .center)
                            }
                            .navigationBarTitle("Settings")
                            .alert(isPresented: $showResetAlert) {
                                Alert(
                                    title: Text("Reset Profile"),
                                    message: Text("Are you sure you want to reset your profile settings?"),
                                    primaryButton: .destructive(Text("Reset")) {
                                        resetProfile()
                                    },
                                    secondaryButton: .cancel()
                                )
            }
            .navigationBarTitle("Settings")
        }
        .onAppear {
            settingsManager.fetchStepCount()
            
        }
        .onChange(of: settingsManager.stepCount) { newStepCount in
            if let newStepCount = newStepCount, let stepGoal = Double(stepGoalText), isStepGoalValid {
                settingsManager.compareStepCountWithGoal(newStepCount, goal: stepGoal)
            }
        }
        .onChange(of: settingsManager.error) { newError in
            if let error = newError {
                errorMessage = error.error.localizedDescription
                isErrorOccurred = true
            } else {
                isErrorOccurred = false
            }
        }
    }
    func zoneRangeText(for index: Int) -> String {
            if index == 0 {
                zone1Min = "40"
                zone1Max = "\(heartRateZones[index])"
                return "40 - \(heartRateZones[index])"
                
            } else if index == heartRateZones.count - 1 {
                zone5Min = "\(heartRateZones[index - 1] + 1)"
                zone5Max = "\(heartRateZones[index])"
                return "\(heartRateZones[index - 1] + 1) - \(heartRateZones[index])"
            } else {
                switch index {
                case 1:
                    zone2Min = "\(heartRateZones[index - 1] + 1)"
                    zone2Max = "\(heartRateZones[index])"
                case 2:
                    zone3Min = "\(heartRateZones[index - 1] + 1)"
                    zone3Max = "\(heartRateZones[index])"
                case 3:
                    zone4Min = "\(heartRateZones[index - 1] + 1)"
                    zone4Max = "\(heartRateZones[index])"
                default:
                    break
                }
                return "\(heartRateZones[index - 1] + 1) - \(heartRateZones[index])"
            }
        }
        
        func zoneColor(for index: Int) -> Color {
            switch index {
            case 0:
                return .blue
            case 1:
                return .green
            case 2:
                return .yellow
            case 3:
                return .orange
            case 4:
                return .red
            default:
                return .black
            }
        }
    
    private func resetProfile() {
            if let bundleIdentifier = Bundle.main.bundleIdentifier {
                // Remove UserDefaults data
                UserDefaults.standard.removePersistentDomain(forName: bundleIdentifier)
                UserDefaults.standard.synchronize()
                
                // Remove profile picture
                profileViewModel.removeProfilePicture()
                
                // Notify user of reset completion
                print("Profile Reset")
            }
        }
    }
    
extension String {
    func trimmingTrailingZeros() -> String {
        guard let doubleValue = Double(self) else {
            return self
        }
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 10
        return formatter.string(from: NSNumber(value: doubleValue)) ?? self
    }
}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
