//
//  Workout.swift
//  WatchTheZone Watch App
//
//  Created by Alex Brankin on 09/04/2024.
//

import Foundation

struct Workout: Identifiable {
    let id = UUID()
    let title: String
    let totalTime: TimeInterval
    let averageHeartRate: Int
    let maxHeartRate: Int
    let zoneTimes: [String: TimeInterval]
    let distance: Double
    let caloriesBurned: Double
}

let previousWorkouts: [Workout] = [
    Workout(
        title: "Workout 1",
        totalTime: 3600, // 1 hour workout
        averageHeartRate: 130,
        maxHeartRate: 160,
        zoneTimes: [
            "Zone 1": 600, // 10 minutes in zone 1
            "Zone 2": 1800, // 30 minutes in zone 2
            "Zone 3": 1200, // 20 minutes in zone 3
            "Zone 4": 600, // 10 minutes in zone 4
            "Zone 5": 0 // No time in zone 5
        ],
        distance: 5.0, // 5 kilometers
        caloriesBurned: 350 // 350 calories burned
    ),
    Workout(
        title: "Workout 2",
        totalTime: 2700, // 45 minutes workout
        averageHeartRate: 140,
        maxHeartRate: 170,
        zoneTimes: [
            "Zone 1": 1200, // 20 minutes in zone 1
            "Zone 2": 600, // 10 minutes in zone 2
            "Zone 3": 600, // 10 minutes in zone 3
            "Zone 4": 300, // 5 minutes in zone 4
            "Zone 5": 0 // No time in zone 5
        ],
        distance: 4.0, // 4 kilometers
        caloriesBurned: 300 // 300 calories burned
    )
]

