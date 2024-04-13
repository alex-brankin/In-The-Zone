//
//  YourHeartView.swift
//  InTheZone
//
//  Created by Alex Brankin on 03/04/2024.
//

import SwiftUI
import HealthKit

struct YourHeartView: View {
    
    var body: some View {
        ScrollView {
            VStack {
                // Heart View (BPM in Heart)
                HRView()
                
                // Boxes
                HeartTabsView()
                
                // Heart Rate Zones Graph
                HRZoneChartView()
                
                Spacer()
            }
            .padding() // Add some padding for better spacing
        }
    }
}

struct YourHeartView_Previews: PreviewProvider {
    static var previews: some View {
        YourHeartView()
    }
}

