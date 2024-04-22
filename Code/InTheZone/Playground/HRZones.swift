//
//  HRZones.swift
//  InTheZone
//
//  Created by Alex Brankin on 20/04/2024.
//

import SwiftUI

struct WorkoutZonesView: View {
    let workoutZones: [String: ClosedRange<Double>] // Workout zones obtained from UserData
    
    var body: some View {
        VStack {
            Text("Workout Zones").font(.title)
            
            // Iterate over the workout zones and display them
            ForEach(workoutZones.sorted(by: { $0.key < $1.key }), id: \.key) { zoneName, range in
                Text("\(zoneName): \(Int(range.lowerBound * 100))% - \(Int(range.upperBound * 100))%")
            }
        }
        .padding()
    }
}
