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
    let heartRateData: [HeartRateData]
}

struct HeartRateData: Identifiable {
    let id = UUID()
    let time: String
    let heartRate: Int
    let zone: String
}

let previousWorkouts = [
    Workout(title: "Workout 1", heartRateData: [
        HeartRateData(time: "00:05", heartRate: 120, zone: "Fat Burn"),
        HeartRateData(time: "00:10", heartRate: 135, zone: "Cardio"),
        HeartRateData(time: "00:15", heartRate: 150, zone: "Peak")
    ]),
    Workout(title: "Workout 2", heartRateData: [
        HeartRateData(time: "00:05", heartRate: 110, zone: "Fat Burn"),
        HeartRateData(time: "00:10", heartRate: 125, zone: "Cardio"),
        HeartRateData(time: "00:15", heartRate: 140, zone: "Peak")
    ])
]
