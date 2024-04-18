//
//  MaxHeartRate.swift
//  InTheZone
//
//  Created by Alex Brankin on 17/04/2024.
//

import SwiftUI

class MaxHeartRateManager: ObservableObject {
    static let shared = MaxHeartRateManager()
    
    @Published var maxHeartRate: Int {
        didSet {
            UserDefaults.standard.set(maxHeartRate, forKey: "maxHeartRate")
        }
    }
    
    private init() {
        self.maxHeartRate = UserDefaults.standard.integer(forKey: "maxHeartRate")
    }
}
