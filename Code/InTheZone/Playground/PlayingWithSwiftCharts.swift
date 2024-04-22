//
//  PlayingWithSwiftCharts.swift
//  InTheZone
//
//  Created by Alex Brankin on 19/04/2024.
//

import Charts
import SwiftUI

struct DailyRestingView: Identifiable {
    let id = UUID()
    let date: Date
    let RestingHeardRate: Double
}

struct RestingGraph: View {
    @EnvironmentObject var healthKitManager: HealthKitManager
    
    var body: some View {
        VStack {
            if !healthKitManager.oneMonthChartData.isEmpty {
                Chart {
                    ForEach(healthKitManager.oneMonthChartData) { daily in
                        LineMark(
                            x: .value(daily.date.formatted(), daily.date, unit: .day),
                            y: .value("Heart Rate", daily.RestingHeardRate))
                    }
                }
                .padding()
            } else {
                Text("Loading data...")
            }
        }
        
        .onAppear{
            print(healthKitManager.oneMonthChartData)
        }
    }
}

struct SalesGraph_Previews: PreviewProvider {
    static var previews: some View {
        RestingGraph()
            .environmentObject(HealthKitManager())
    }
}
