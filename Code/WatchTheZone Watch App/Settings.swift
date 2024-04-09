//
//  Settings.swift
//  WatchTheZone Watch App
//
//  Created by Alex Brankin on 09/04/2024.
//

import Foundation

class SettingsModel: ObservableObject {
    @Published var workoutDuration: Int = 30 // Default workout duration in minutes
    @Published var intensity: Int = 5 // Default intensity on a scale of 1-10
    @Published var heartRateZone: Int = 5 // Default heart rate zone on a scale of 1-5
    
}
