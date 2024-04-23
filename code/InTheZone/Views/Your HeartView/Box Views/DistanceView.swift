//
//  DistanceView.swift
//  InTheZone
//
//  Created by Alex Brankin on 17/04/2024.
//

import SwiftUI
import HealthKit
import Charts

struct DailyDistanceView: Identifiable {
    let id = UUID()
    let date: Date
    let distance: Double
}

struct DistanceView: View {
    @State private var selectedRange: String = "7D"
    let dateRanges = ["7D", "30D", "1Y"]
    private let healthStore = HKHealthStore()
    @EnvironmentObject var manager: HealthKitManager
    
    var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Picker("Select Range", selection: $selectedRange) {
                        ForEach(dateRanges, id: \.self) { range in
                            Text(range)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    
                    Chart {
                        ForEach(manager.oneMonthChartData) { daily in
                            LineMark(
                                x: .value(daily.date.formatted(), daily.date, unit: .day),
                                y: .value("Distance", daily.distance)
                            )
                            .foregroundStyle(.blue)
                        }
                    }
                    .frame(height: 200)
                    .padding(.horizontal)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                print(manager.oneMonthChartData)
                
            }
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
    }
}

struct DistanceInfoView_Previews: PreviewProvider {
    static var previews: some View {
        DistanceInfoView()
    }
}


#Preview {
    DistanceView()
        .environmentObject(HealthKitManager())
}
