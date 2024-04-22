//
//  HRVView.swift
//  InTheZone
//
//  Created by Alex Brankin on 17/04/2024.
//

import SwiftUI

struct HRVView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct HRVInfoView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
                
            
            Text("Heart rate variability (HRV) is the variation in time between each heartbeat. It's considered an indicator of the autonomic nervous system's activity and can reflect the body's ability to respond to stress.")
                .font(.body)
                .foregroundColor(.secondary)
            
            Divider()
            
            Text("Factors Affecting HRV:")
                .font(.headline)
            
            Text("1. Stress: Higher stress levels can lead to decreased HRV.")
                .font(.body)
                .foregroundColor(.secondary)
            
            Text("2. Exercise: Regular exercise can improve HRV.")
                .font(.body)
                .foregroundColor(.secondary)
            
            Text("3. Sleep: Quality sleep is associated with higher HRV.")
                .font(.body)
                .foregroundColor(.secondary)
            
            Divider()
            
            Text("HRV Monitoring:")
                .font(.headline)
            
            Text("HRV can be monitored using specialized devices or certain fitness trackers. Tracking changes in HRV over time may provide insights into overall health and fitness.")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white)
        .padding()
    }
}

struct HRVInfoView_Previews: PreviewProvider {
    static var previews: some View {
        HRVInfoView()
    }
}



#Preview {
    HRVView()
}
