//
//  SettingsView.swift
//  InTheZone
//
//  Created by Alex Brankin on 03/04/2024.
//

import SwiftUI

struct SettingsView: View {
    @State private var notificationsEnabled = false
    @State private var notificationInterval = 15
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Notifications")) {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                    
                    if notificationsEnabled {
                        Stepper(value: $notificationInterval, in: 5...60, step: 5) {
                            Text("Notification Interval: \(notificationInterval) minutes")
                        }
                    }
                }
                
                Section(header: Text("Account")) {
                    Button(action: {
                        // Add action for sign out
                    }) {
                        Text("Sign Out")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationBarTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
