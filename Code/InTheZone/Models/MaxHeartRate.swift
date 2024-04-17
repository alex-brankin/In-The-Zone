//
//  MaxHeartRate.swift
//  InTheZone
//
//  Created by Alex Brankin on 17/04/2024.
//

import Foundation

class MaxHeartRateManager: ObservableObject {
    static let shared = MaxHeartRateManager()
    @Published var maxHeartRate: Int = UserDefaults.standard.integer(forKey: "maxHeartRate") {
        didSet {
            UserDefaults.standard.set(maxHeartRate, forKey: "maxHeartRate") // Save to UserDefaults
        }
    }
}
