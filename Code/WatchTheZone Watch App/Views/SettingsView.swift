//
//  SettingsView.swift
//  WatchTheZone Watch App
//
//  Created by Alex Brankin on 09/04/2024.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: SettingsModel
    
    var body: some View {
        List {
            Section(header: Text("Workout Duration")) {
                Stepper(value: $settings.workoutDuration, in: 1...60) {
                    Text("\(settings.workoutDuration) minutes")
                }
            }
            
            Section(header: Text("Intensity")) {
                Stepper(value: $settings.intensity, in: 1...10) {
                    Text("Intensity \(settings.intensity)")
                }
            }
            
            Section(header: Text("Heart Rate Zone")) {
                Stepper(value: $settings.heartRateZone, in: 1...5) {
                    Text("Zone \(settings.heartRateZone)")
                }
            }
            
            // Add more sections as needed for additional settings
        }
        .navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(settings: SettingsModel())
    }
}
