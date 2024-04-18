//
//  SettingsView.swift
//  WatchTheZone Watch App
//
//  Created by Alex Brankin on 09/04/2024.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("distanceUnit") var distanceUnit: String = DistanceUnit.kilometers.rawValue
    @AppStorage("hapticFeedbackEnabled") var hapticFeedbackEnabled = false
    @AppStorage("hapticDelayMinutes") var hapticDelayMinutes: Double = 0
    @AppStorage("hapticFrequencyMinutes") var hapticFrequencyMinutes: Double = 1
    @AppStorage("workoutCountdownEnabled") var workoutCountdownEnabled = false
    
    var body: some View {
        ScrollView {
            VStack {
                VStack {
                    Text("Distance Unit")
                        .padding(.bottom, -15)
                    Picker(selection: $distanceUnit, label: Text("")) {
                        Text("Miles").tag(DistanceUnit.miles.rawValue)
                        Text("Kilometres").tag(DistanceUnit.kilometers.rawValue)
                    }
                    .pickerStyle(DefaultPickerStyle())
                    .frame(height: 60)
                    .padding(.bottom,10)
                }
                
                Toggle("Countdown", isOn: $workoutCountdownEnabled)
                
                Section(header: Text("Haptic Feedback").foregroundColor(.blue)) {
                    Toggle("Enabled", isOn: $hapticFeedbackEnabled)
                    
                    VStack(alignment: .leading) {
                        Text("Delay: \(Int(hapticDelayMinutes)) minutes")
                        Slider(value: $hapticDelayMinutes, in: 0...20, step: 1)
                            .frame(width: 180) // Adjust slider width here
                            .disabled(!hapticFeedbackEnabled) // Disable if haptic feedback is not enabled
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Frequency: \(Int(hapticFrequencyMinutes)) minutes")
                        Slider(value: $hapticFrequencyMinutes, in: 1...10, step: 1)
                            .frame(width: 180) // Adjust slider width here
                            .disabled(!hapticFeedbackEnabled) // Disable if haptic feedback is not enabled
                    }
                }
                Spacer()
            }
            .padding()
        }
    }
}

enum DistanceUnit: String {
    case miles
    case kilometers
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
