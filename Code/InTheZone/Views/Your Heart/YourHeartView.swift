//
//  InTheZone
//
//  Created by Alex Brankin on 02/03/2024.
//
//
// The YourHeartView in SwiftUI provides a comprehensive visualization of a user's heart health, utilizing
// components like HRView for real-time BPM display and HeartTabsView for quick access to different heart-related
// metrics. It incorporates a BPMZonesCharts view, which uses a WorkoutAnalyzer instance to graphically represent
// heart rate zones over workouts, helping users understand their cardiovascular performance. The view is designed
// with a scrollable vertical layout, ensuring all components are accessible within a seamless and user-friendly
// interface.

import SwiftUI
import HealthKit

struct YourHeartView: View {
    let workoutAnalyzer = WorkoutAnalyzer()
    
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
                BPMZonesCharts(workoutAnalyzer: workoutAnalyzer)
                
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

