//
//  MaxHeartRateView.swift
//  InTheZone
//
//  Created by Alex Brankin on 17/04/2024.
//

import SwiftUI

struct MaxHRView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var userData = UserData()
    @State private var customMaxHeartRate: String = ""

    var body: some View {
        VStack {
            Text("Your Estimated Max Heart Rate: \(userData.calculatedMaxHeartRate)")
                .font(.headline)
                .padding()
            
            Text("Enter your custom max heart rate:")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.bottom, 5)
            
            TextField("Max Heart Rate", text: $customMaxHeartRate)
                .padding()
                .keyboardType(.numberPad)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(8)
                .padding(.bottom, 20)
            
            Button("Save") {
                if let customMaxHR = Int(customMaxHeartRate) {
                    userData.maxHeartRate = customMaxHR
                    print("Custom Max Heart Rate saved: \(customMaxHR)")
                    print("Max Heart Rate saved: \(userData.maxHeartRate)")
                }
                presentationMode.wrappedValue.dismiss()
            }
            .frame(width: 300)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.horizontal)
                        .shadow(radius: 5)
            
            Spacer()
        }
        .padding()
    }
}



struct MaxHeartRateInfoView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
                
            
            Text("Your maximum heart rate is the highest number of heartbeats per minute (bpm) that your body can reach during physical activity.")
                .font(.body)
                .foregroundColor(.secondary)
            
            Divider()
            
            Text("Formula for Estimating Maximum Heart Rate:")
                .font(.headline)
            
            Text("220 - your age")
                .font(.subheadline)
                .foregroundColor(.red)
                .padding(.bottom, 10)
            
            Divider()
            
            Text("It's important to note that this is a general estimation and may not be accurate for everyone. Factors such as fitness level, genetics, and overall health can influence your maximum heart rate.")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

struct MaxHeartRateInfoView_Previews: PreviewProvider {
    static var previews: some View {
        MaxHeartRateInfoView()
    }
}




struct MaxHRView_Previews: PreviewProvider {
    static var previews: some View {
        MaxHRView()
    }
}