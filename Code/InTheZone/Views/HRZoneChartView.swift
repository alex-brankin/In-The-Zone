//
//  HRZoneChartView.swift
//  InTheZone
//
//  Created by Alex Brankin on 09/04/2024.
//

import SwiftUI

struct HRZoneChartView: View {
    let maxHeartRate: Double = 195 // Maximum heart rate
    
    struct ZoneData {
        var name: String
        var startAngle: Double
        var endAngle: Double
        var color: Color
        var bpmRange: (min: Double, max: Double)
    }

    var body: some View {
        VStack {
            Text("Your Average Workout Zones")
                .font(.title2)
                .fontWeight(.bold)
                .padding()
            
            HStack(spacing: 20) {
                HeartRateZonesGraph(zoneData: calculateZoneData())
                LegendView(zoneData: calculateZoneData())
            }
            .padding()
        }
    }

    func calculateZoneData() -> [ZoneData] {
        let zoneData: [ZoneData] = [
            ZoneData(name: "Zone 1", startAngle: 0, endAngle: (0.5 * 360), color: .blue, bpmRange: (0.5 * maxHeartRate, 0.6 * maxHeartRate)),
            ZoneData(name: "Zone 2", startAngle: (0.5 * 360), endAngle: (0.6 * 360), color: .green, bpmRange: (0.6 * maxHeartRate, 0.7 * maxHeartRate)),
            ZoneData(name: "Zone 3", startAngle: (0.6 * 360), endAngle: (0.7 * 360), color: .yellow, bpmRange: (0.7 * maxHeartRate, 0.8 * maxHeartRate)),
            ZoneData(name: "Zone 4", startAngle: (0.7 * 360), endAngle: (0.8 * 360), color: .red, bpmRange: (0.8 * maxHeartRate, 0.9 * maxHeartRate)),
            ZoneData(name: "Zone 5", startAngle: (0.8 * 360), endAngle: 360, color: .purple, bpmRange: (0.9 * maxHeartRate, maxHeartRate))
        ]
        return zoneData
    }
}

// Heart Rate Zones Graph component
struct HeartRateZonesGraph: View {
    let zoneData: [HRZoneChartView.ZoneData] // Array of heart rate zone data
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(zoneData.indices, id: \.self) { index in
                    HeartRateZoneShape(startAngle: zoneData[index].startAngle,
                                        endAngle: zoneData[index].endAngle)
                        .fill(zoneData[index].color)
                        .opacity(0.8)
                        .rotationEffect(Angle(degrees: -90))
                        .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 200) // Adjust height as needed
    }
}

// Custom shape for heart rate zone
struct HeartRateZoneShape: Shape {
    var startAngle: Double
    var endAngle: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let radius = min(rect.width, rect.height) / 2
        
        path.move(to: center)
        path.addArc(center: center, radius: radius, startAngle: Angle(degrees: startAngle), endAngle: Angle(degrees: endAngle), clockwise: false)
        path.closeSubpath()
        
        return path
    }
}

// Legend View
struct LegendView: View {
    let zoneData: [HRZoneChartView.ZoneData] // Array of heart rate zone data
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            ForEach(zoneData.indices, id: \.self) { index in
                HStack {
                    Rectangle()
                        .fill(zoneData[index].color)
                        .frame(width: 20, height: 10)
                    Text("\(zoneData[index].name) - \(Int(zoneData[index].bpmRange.min))-\(Int(zoneData[index].bpmRange.max))")
                        .font(.caption)
                }
            }
        }
        .padding(10)
    }
}

struct HRZoneChartView_Previews: PreviewProvider {
    static var previews: some View {
        HRZoneChartView()
    }
}

