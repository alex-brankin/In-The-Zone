//
//  HRView.swift
//  InTheZone
//
//  Created by Alex Brankin on 02/04/2024.
//

import SwiftUI

struct HRView: View {
    @State private var heartRate: Double = 0.0

    var body: some View {
        VStack {
            Text("Heart Rate")
                .font(.largeTitle)
            Text("\(heartRate, specifier: "%.0f") BPM")
                .font(.title)
        }
    }
}

#Preview {
    HRView()
}
