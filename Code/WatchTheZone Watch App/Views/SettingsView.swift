//
//  SettingsView.swift
//  WatchTheZone Watch App
//
//  Created by Alex Brankin on 09/04/2024.
//

import SwiftUI

struct SettingsView: View {
    @State private var autoPauseRunning = false
    @State private var autoPauseCycling = false
    @State private var selectedUnit = MeasurementUnit.kilometers
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Settings")
                .font(.title)
                .foregroundColor(.red)
                .padding(.top, 20)
                .padding(.leading, 10)
            
            List {
                Section(header: Text("Auto-Pause").foregroundColor(.red)) {
                    Toggle("Running", isOn: $autoPauseRunning)
                    Toggle("Cycling", isOn: $autoPauseCycling)
                }
                
                Section(header: Text("Other").foregroundColor(.red)) {
                    HStack {
                        Text("Units")
                            .font(.body)
                        Spacer()
                        Text(selectedUnit.rawValue)
                            .foregroundColor(.blue)
                            .onTapGesture {
                                toggleUnit()
                            }
                    }
                }
            }
        }
    }
    
    func toggleUnit() {
        selectedUnit = (selectedUnit == .kilometers) ? .miles : .kilometers
    }
}

enum MeasurementUnit: String {
    case kilometers = "Kilometers"
    case miles = "Miles"
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

