//
//  InTheZone
//
//  Created by Alex Brankin on 02/03/2024.
//

import SwiftUI
import HealthKit

struct YourHeartView: View {
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                // Heart View (BPM in Heart)
                HRView()
                
                // Boxes
                HeartTabsView()
                    .frame(width: 420, height: 200)
                    .padding(.bottom, 30)
                
                
                // Heart Rate Zones Graph
                BPMZonesCharts()
                        
                       
                
                Spacer()
            }
            .padding(.top, 30) 
            .navigationBarHidden(true)
        }
        
    }
}

struct YourHeartView_Previews: PreviewProvider {
    static var previews: some View {
        YourHeartView()
    }
}

