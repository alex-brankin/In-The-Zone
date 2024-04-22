//
//  ActiveEnergyView.swift
//  InTheZone
//
//  Created by Alex Brankin on 17/04/2024.
//

import SwiftUI

struct ActiveEnergyView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct ActiveEnergyInfoView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
                
            
            Text("Active energy represents the amount of energy expended during physical activity. It's often measured in kilocalories (kcal) or kilojoules (kJ) and can provide insights into the intensity and duration of exercise.")
                .font(.body)
                .foregroundColor(.secondary)
            
            Divider()
            
            Text("Measuring Active Energy:")
                .font(.headline)
            
            Text("1. Fitness Trackers: Many fitness trackers can estimate active energy expenditure based on activity type, duration, and heart rate.")
                .font(.body)
                .foregroundColor(.secondary)
            
            Text("2. Smartwatches: Smartwatches with built-in fitness features often track active energy during workouts.")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white)
        .padding()
    }
}

struct ActiveEnergyInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ActiveEnergyInfoView()
    }
}


#Preview {
    ActiveEnergyView()
}
