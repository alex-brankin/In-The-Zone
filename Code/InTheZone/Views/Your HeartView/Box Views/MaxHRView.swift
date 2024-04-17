//
//  MaxHeartRateView.swift
//  InTheZone
//
//  Created by Alex Brankin on 17/04/2024.
//

import SwiftUI

struct MaxHRView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var customMaxHeartRate: Int = MaxHeartRateManager.shared.maxHeartRate

    var body: some View {
        VStack {
            Text("Customize Max Heart Rate")
                .font(.headline)
                .padding()
            
            Text("Enter your custom max heart rate:")
                .font(.subheadline)
            
            TextField("Max Heart Rate", value: $customMaxHeartRate, formatter: NumberFormatter())
                .padding()
                .keyboardType(.numberPad)
            
            Button("Save") {
                MaxHeartRateManager.shared.maxHeartRate = customMaxHeartRate
                UserDefaults.standard.set(customMaxHeartRate, forKey: "maxHeartRate")
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
            
            Spacer()
        }
        .padding()
    }
}
