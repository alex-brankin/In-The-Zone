//
//  VO2MaxView.swift
//  InTheZone
//
//  Created by Alex Brankin on 17/04/2024.
//

import SwiftUI

struct VO2MaxView: View {
    @State private var selectedDuration = 1 // Default to 1 day
    
    var body: some View {
        VStack {
            Picker(selection: $selectedDuration, label: Text("Duration")) {
                Text("1D").tag(1)
                Text("7D").tag(7)
                Text("30D").tag(30)
                Text("1Y").tag(365)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            Text("Selected Duration: \(selectedDuration)")
            
            // Add your VO2 max calculation logic here based on the selected duration
        }
    }
}

struct VO2MaxInfoView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
                
            
            Text("VO2 max, or maximal oxygen consumption, is the maximum rate of oxygen consumption measured during incremental exercise. It reflects the aerobic physical fitness of an individual and is an important indicator of cardiovascular health.")
                .font(.body)
                .foregroundColor(.secondary)
            
            Divider()
            
            Text("Factors Affecting VO2 Max:")
                .font(.headline)
            
            Text("1. Genetics: Genetics play a significant role in determining an individual's VO2 max.")
                .font(.body)
                .foregroundColor(.secondary)
            
            Text("2. Age: VO2 max tends to decrease with age, particularly after reaching middle age.")
                .font(.body)
                .foregroundColor(.secondary)
            
            Text("3. Training: Regular physical activity and cardiovascular exercise can improve VO2 max over time.")
                .font(.body)
                .foregroundColor(.secondary)
            
        }
        .padding()
        .background(Color.white)
        .padding()
    }
}

struct VO2MaxInfoView_Previews: PreviewProvider {
    static var previews: some View {
        VO2MaxInfoView()
    }
}


struct VO2MaxView_Previews: PreviewProvider {
    static var previews: some View {
        VO2MaxView()
    }
}
