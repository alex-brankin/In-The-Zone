//
//  Workout.swift
//  InTheZone
//
//  Created by Alex Brankin on 15/04/2024.
//

import Foundation

struct Workout: Identifiable {
    var id = UUID()
    var title: String
    var duration: String
    var date: String
    var symbol: String
}
