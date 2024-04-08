//
//  YourHeartView.swift
//  InTheZone
//
//  Created by Alex Brankin on 03/04/2024.
//

import SwiftUI
import HealthKit

struct YourHeartView: View {
    
    let zoneData: [ZoneData] = [
        ZoneData(name: "Zone 1", startAngle: 0, endAngle: 60, color: .blue),
        ZoneData(name: "Zone 2", startAngle: 60, endAngle: 180, color: .green),
        ZoneData(name: "Zone 3", startAngle: 180, endAngle: 240, color: .yellow),
        ZoneData(name: "Zone 4", startAngle: 240, endAngle: 360, color: .red)
    ]
    
    var body: some View {
        VStack {
            HRView() // Use HRView to fetch heart rate data
                .padding()
            

            // Boxes
            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2)) {
                BoxedView(title: "Max Heart Rate", value: "N/A")
                BoxedView(title: "VO2 Max", value: "N/A")
                BoxedView(title: "HRV", value: "N/A")
                BoxedView(title: "Resting Heart Rate", value: "N/A")
            }
            .padding()
            .padding(.top, -30)
            
            // Heart Rate Zones Graph
            HStack {
                HeartRateZonesGraph(zoneData: zoneData)
                LegendView(zoneData: zoneData)
            }
            .padding()
            
            Spacer()
        }
    }
}

// Heart Rate Zones Graph component
struct HeartRateZonesGraph: View {
    let zoneData: [ZoneData] // Array of heart rate zone data
    
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

// Struct to represent heart rate zone data
struct ZoneData {
    var name: String
    var startAngle: Double
    var endAngle: Double
    var color: Color
}

// Legend View
struct LegendView: View {
    let zoneData: [ZoneData] // Array of heart rate zone data
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            ForEach(zoneData.indices, id: \.self) { index in
                HStack {
                    Rectangle()
                        .fill(zoneData[index].color)
                        .frame(width: 20, height: 10)
                    Text(zoneData[index].name)
                        .font(.caption)
                }
            }
        }
        .padding(10)
    }
}

struct BoxedView: View {
    var title: String
    var value: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
            Text(value)
                .font(.subheadline)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Set a fixed size for each box
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
    }
}

struct YourHeartView_Previews: PreviewProvider {
    static var previews: some View {
        YourHeartView()
    }
}
