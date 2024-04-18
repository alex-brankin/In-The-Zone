//
//  HRVView.swift
//  InTheZone
//
//  Created by Alex Brankin on 08/04/2024.
//

import SwiftUI
import HealthKit

struct HRVView: View {
    @State private var dailyAverageHRV: Double?
    private let healthKitManager = HealthKitManager()

    var body: some View {
        VStack {
            if let hrv = dailyAverageHRV {
                BoxedView(title: "HRV", value: "\(hrv) ms")
            } else {
                ProgressView("Fetching HRV...")
                    .padding()
                    .onAppear {
                        fetchHRV()
                    }
            }
        }
        .onAppear {
            healthKitManager.requestAuthorization { success in
                guard success else {
                    print("Authorization failed")
                    return
                }
            }
        }
    }

    private func fetchHRV() {
        healthKitManager.fetchDailyAverageHRV { averageHRV, error in
            guard let averageHRV = averageHRV, error == nil else {
                print("Failed to fetch HRV: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            DispatchQueue.main.async {
                dailyAverageHRV = averageHRV
            }
        }
    }
}

struct HRVView_Previews: PreviewProvider {
    static var previews: some View {
        HRVView()
    }
}
