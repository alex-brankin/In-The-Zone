//
//  WatchTheZone
//
//  Created by Alex Brankin on 13/03/2024.
//
// The SettingsView in the WatchTheZone app allows users to customize various workout settings
// directly from their device. This view includes settings for selecting distance units, configuring
// heart rate zones, enabling a workout countdown, and managing haptic feedback settings with
// options for delay and frequency adjustments. Additionally, it offers a user-friendly interface
// with color-coded text for different heart rate zones and interactive sliders for precise control
// over haptic feedback settings.

import SwiftUI

struct SettingsView: View {
    

    @AppStorage("distanceUnit") var distanceUnit: String = DistanceUnit.kilometers.rawValue
    @AppStorage("hapticFeedbackEnabled") var hapticFeedbackEnabled = true
    @AppStorage("hapticDelayMinutes") var hapticDelayMinutes: Double = 2
    @AppStorage("hapticFrequencyMinutes") var hapticFrequencyMinutes: Double = 1
    @AppStorage("workoutCountdownEnabled") var workoutCountdownEnabled = false
    @AppStorage("maxHeartRate") var maxHeartRate = ""
    @AppStorage("zone1Min") private var zone1Min = "40"
    @AppStorage("zone1Max") private var zone1Max = "100"
    @AppStorage("zone2Min") private var zone2Min = "101"
    @AppStorage("zone2Max") private var zone2Max = "120"
    @AppStorage("zone3Min") private var zone3Min = "121"
    @AppStorage("zone3Max") private var zone3Max = "140"
    @AppStorage("zone4Min") private var zone4Min = "141"
    @AppStorage("zone4Max") private var zone4Max = "160"
    @AppStorage("zone5Min") private var zone5Min = "161"
    @AppStorage("zone5Max") private var zone5Max = "180"
    
    
    var body: some View {
        ScrollView {Text("Heart Rate Zones")
                .padding(.bottom, -10)
            VStack(alignment: .leading) {
                Text("Zone 1 : \(zone1Min) - \(zone1Max) bpm").foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                Text("Zone 2 : \(zone2Min) - \(zone2Max) bpm").foregroundColor(.green)
                Text("Zone 3 : \(zone3Min) - \(zone3Max) bpm").foregroundColor(.yellow)
                Text("Zone 4 : \(zone4Min) - \(zone4Max) bpm").foregroundColor(.orange)
                Text("Zone 5 : \(zone5Min) - \(zone5Max) bpm").foregroundColor(.red)
                    .padding(.bottom, 10)
            
                
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
                            .frame(width: 180)
                            .disabled(!hapticFeedbackEnabled)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Frequency: \(Int(hapticFrequencyMinutes)) minutes")
                        Slider(value: $hapticFrequencyMinutes, in: 1...10, step: 1)
                            .frame(width: 180)
                            .disabled(!hapticFeedbackEnabled)
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
