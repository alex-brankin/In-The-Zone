//
//  CircleAnimation.swift
//  WatchTheZone Watch App
//
//  Created by Alex Brankin on 13/04/2024.
//

import SwiftUI

struct Test: View {
    let zoneColors: [Color] = [.blue, .green, .yellow, .orange, .red]
    let zonePercentages: [Double] = [0.05, 0.5, 0.1, 0.1, 0.25]
    
    var body: some View {
        ZStack {
            ForEach(0..<zonePercentages.count) { index in
                Circle()
                    .trim(from: index == 0 ? 0 : zonePercentages[..<index].reduce(0, +), to: zonePercentages[..<index].reduce(0, +) + zonePercentages[index])
                    .stroke(zoneColors[index], lineWidth: 20)
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))
            }
        }
    }
}

struct ContentTest_Previews: PreviewProvider {
    static var previews: some View {
        Test()
    }
}






