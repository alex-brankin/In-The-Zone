//
//  DistanceView.swift
//  InTheZone
//
//  Created by Alex Brankin on 17/04/2024.
//

import SwiftUI

struct DistanceView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct DistanceInfoView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
                
            
            Text("Distance travelled is a measure of the total distance covered by an individual over a certain period. It's often used to track outdoor activities such as walking, running, or cycling.")
                .font(.body)
                .foregroundColor(.secondary)
            
            Divider()
            
            Text("Tracking Distance:")
                .font(.headline)
            
            Text("1. GPS Devices: GPS-enabled devices can accurately track distance travelled during outdoor activities.")
                .font(.body)
                .foregroundColor(.secondary)
            
            Text("2. Fitness Trackers: Many fitness trackers can estimate distance based on step count and stride length.")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white)
        .padding()
    }
}

struct DistanceInfoView_Previews: PreviewProvider {
    static var previews: some View {
        DistanceInfoView()
    }
}


#Preview {
    DistanceView()
}
