//
//  RestingHRView.swift
//  InTheZone
//
//  Created by Alex Brankin on 17/04/2024.
//

import SwiftUI
import SwiftUICharts
import HealthKit

struct RestingHRView: View {
    @State private var restingHeartRates: [Double] = []
    @State private var dates: [Date]?
    @State private var error: Error?
    let healthManager = HealthKitManager()

    var body: some View {
        VStack {

            if !restingHeartRates.isEmpty {
                LineView(data: restingHeartRates, title: "Resting Heart Rate", legend: "Last 7 Days")
                    .padding()
            } else if let error = error {
                Text("Error: \(error.localizedDescription)")
                    .foregroundColor(.red)
                    .padding()
            } else {
                ProgressView("Fetching Resting Heart Rate...")
                    .padding()
            }
        }
        .onAppear {
            fetchRestingHeartRates()
        }
    }

    func fetchRestingHeartRates() {
        healthManager.fetchRestingHeartRate(forLastDays: 7) { restingHeartRates, dates, error in
            if let error = error {
                self.error = error
            } else if let restingHeartRates = restingHeartRates {
                self.restingHeartRates = restingHeartRates
                self.dates = dates
            }
        }
    }
}

struct RestingHeartRateChartView_Previews: PreviewProvider {
    static var previews: some View {
        RestingHRView()
    }
}
