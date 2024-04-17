//
//  SettingsView.swift
//  InTheZone
//
//  Created by Alex Brankin on 03/04/2024.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @State private var stepGoalText = "10000"
    @State private var isStepGoalValid = true
    @StateObject private var settingsManager = SettingsManager()
    @State private var isErrorOccurred = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Notifications")) {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) { newValue in
                            UserDefaults.standard.setValue(newValue, forKey: "notificationsEnabled")
                            settingsManager.requestNotificationPermission()
                        }
                }
                
                Section(header: Text("Step Goal")) {
                    TextField("Enter Step Goal", text: $stepGoalText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                        .foregroundColor(isStepGoalValid ? .primary : .red)
                        .onChange(of: stepGoalText) { newValue in
                            isStepGoalValid = settingsManager.isValidStepGoal(newValue)
                        }
                }
                
                if !isStepGoalValid {
                    Text("Please enter a valid step goal").foregroundColor(.red)
                }
                
                if isErrorOccurred {
                    Text(errorMessage).foregroundColor(.red)
                }
                
                Section(header: Text("Account")) {
                    Button(action: {
                        // Implement sign out logic here
                    }) {
                        Text("Sign Out")
                            .foregroundColor(.red)
                    }
                }
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
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
