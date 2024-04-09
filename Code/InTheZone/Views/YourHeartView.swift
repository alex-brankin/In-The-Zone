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
        VStack {
            // Heart View (BPM in Heart)
            HRView()
                
            

            // Boxes
            HeartTabsView()
            
            // Heart Rate Zones Graph
            HRZoneChartView()
            

            Spacer()
        }
    }
}


struct YourHeartView_Previews: PreviewProvider {
    static var previews: some View {
        YourHeartView()
    }
}
