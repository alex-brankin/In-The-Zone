//
//  LineChart.swift
//  InTheZone
//
//  Created by Alex Brankin on 17/04/2024.
//

import SwiftUI

struct LineChart: View {
    var dataPoints: [CGFloat]
    var legend: String

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text(legend)
                    .font(.headline)
                    .padding(.bottom, 8)
                
                ZStack {
                    // Background grid
                    Path { path in
                        let yAxisSpacing = (geometry.size.height - 40) / CGFloat(dataPoints.count - 1)
                        for i in 0..<dataPoints.count {
                            let y = yAxisSpacing * CGFloat(i) + 20
                            path.move(to: CGPoint(x: 0, y: y))
                            path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                        }
                    }
                    .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round))
                    
                    // Data points
                    Path { path in
                        let yAxisSpacing = (geometry.size.height - 40) / CGFloat(dataPoints.count - 1)
                        for i in 0..<dataPoints.count {
                            let x = geometry.size.width / CGFloat(dataPoints.count - 1) * CGFloat(i)
                            let y = geometry.size.height - (CGFloat(dataPoints[i]) / dataPoints.max()!) * (geometry.size.height - 40)
                            if i == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .stroke(Color.red, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                }
                .padding(.vertical, 20)
            }
        }
    }
}

struct LineChart_Previews: PreviewProvider {
    static var previews: some View {
        LineChart(dataPoints: [20, 30, 45, 55, 40, 50, 60], legend: "Sample Data")
            .frame(height: 200)
            .padding()
    }
}
