//
//  RestingEnergyView.swift
//  InTheZone
//
//  Created by Alex Brankin on 17/04/2024.
//

import SwiftUI

struct RestingEnergyView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct RestingEnergyInfoView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
                
            
            Text("Resting energy expenditure (REE) is the amount of energy expended by the body at rest to maintain essential physiological functions such as breathing, circulation, and cellular activity. It's often expressed in kilocalories (kcal) per day.")
                .font(.body)
                .foregroundColor(.secondary)
            
            Divider()
            
            Text("Factors Affecting Resting Energy:")
                .font(.headline)
            
            Text("1. Basal Metabolic Rate (BMR): Resting energy expenditure is closely related to BMR, which is influenced by factors such as age, sex, weight, and body composition.")
                .font(.body)
                .foregroundColor(.secondary)
            
            Text("2. Muscle Mass: Individuals with higher muscle mass typically have higher resting energy expenditure.")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white)
        .padding()
    }
}

struct RestingEnergyInfoView_Previews: PreviewProvider {
    static var previews: some View {
        RestingEnergyInfoView()
    }
}


#Preview {
    RestingEnergyView()
}
