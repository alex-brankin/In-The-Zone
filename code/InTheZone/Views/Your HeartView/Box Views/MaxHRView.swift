//
//  MaxHeartRateView.swift
//  InTheZone
//
//  Created by Alex Brankin on 17/04/2024.
//

import SwiftUI

struct MaxHRView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var maxHeartRateManager = MaxHeartRateManager.shared
    @State private var customMaxHeartRate: Int = 0

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
                maxHeartRateManager.maxHeartRate = customMaxHeartRate
                UserDefaults.standard.set(customMaxHeartRate, forKey: "maxHeartRate")
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
            
            Spacer()
        }
        .padding()
        .onAppear {
            customMaxHeartRate = maxHeartRateManager.maxHeartRate
        }
    }
}


