//
//  HRZoneChartView.swift
//  InTheZone
//
//  Created by Alex Brankin on 09/04/2024.
//

import SwiftUI
import HealthKit
import SwiftUICharts

struct BPMZonesCharts: View {
    @State private var bpmData: [Double] = []
    @State private var error: Error?
    let healthManager = HealthKitManager()
    
    // Sample data for heart rate zones (percentages of max heart rate)
    let maxHeartRate: Double = 200 // Example: replace with actual user input
    let zonePercentages: [Double] = [60, 70, 80, 90, 100] // Example: replace with actual percentages
    let zoneLabels: [String] = ["Zone 1", "Zone 2", "Zone 3", "Zone 4", "Zone 5"] // Example: replace with actual labels

    var body: some View {
        VStack {
            
            HStack {
                Spacer() // Spacer to center align the charts horizontally
                
                VStack {
                    if !bpmData.isEmpty {
                        LineChartView(data: bpmData, title: "BPM", legend: "Today")
                            .frame(width: 160, height: 160) // Adjust the size of the LineChartView
                            .padding()
                    } else if let error = error {
                        Text("Error: \(error.localizedDescription)")
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        LineChartView(data: [], title: "BPM", legend: "Today")
                            .frame(width: 160, height: 160) // Adjust the size of the LineChartView
                            .padding()
                            .overlay(ProgressView("Fetching BPM..."))
                    }
                }
                .onAppear {
                    fetchBPMData()
                }
                
                VStack {
                    // Pie chart displaying heart rate zones
                    PieChartView(data: calculateZonePercentages(), title: "Heart Rate Zones", legend: "Percentage", style: Styles.pieChartStyleOne)
                        .frame(width: 160, height: 160) // Adjust the size of the PieChartView
                        .padding()
                }
                
                Spacer() // Spacer to center align the charts horizontally
            }
            
        }
    }
    
    // Function to calculate the percentage of max heart rate for each zone
    private func calculateZonePercentages() -> [Double] {
        let totalPercentage = zonePercentages.reduce(0, +)
        return zonePercentages.map { $0 / 100 * maxHeartRate / totalPercentage }
    }

    private func fetchBPMData() {
        healthManager.fetchBPMData { bpmData, error in
            if let error = error {
                self.error = error
            } else if let bpmData = bpmData {
                self.bpmData = bpmData
            }
        }
    }
}


struct BPMZonesCharts_Previews: PreviewProvider {
    static var previews: some View {
        BPMZonesCharts()
    }
}

