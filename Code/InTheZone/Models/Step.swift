//
//  InTheZone
//
//  Created by Alex Brankin on 02/03/2024.
//
// The Step struct in Swift defines a model for representing a step count entry, where each entry has a unique
// identifier (id), a step count (count), and a date (date). The unique identifier is automatically generated using
// UUID(), ensuring each instance of Step is distinctly identifiable within the application.

import Foundation

struct Step: Identifiable {
    let id = UUID()
    let count: Int
    let date: Date
}
