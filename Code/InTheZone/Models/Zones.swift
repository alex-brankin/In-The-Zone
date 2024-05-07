
//
//  InTheZone
//
//  Created by Alex Brankin on 02/03/2024.
//
// The following structs define four data models (ZoneCounter, ZoneDefinition, ZoneMinAndMax, HeartRateData) each
// equipped with properties such as unique identifiers, numerical values, and other attributes specific to their
// function in handling heart rate and training zone data in the In The Zone app.

import Foundation
import SwiftUI

struct ZoneCounter: Identifiable {
    let id = UUID()
    let zone: String
    let value: Double
    
}

struct ZoneDefinition: Identifiable {
    let id = UUID()
    let max: Double
    let color: Color
}

struct ZoneMinAndMax: Identifiable {
    let id = UUID()
    let zoneName: String
    let min: Double
    let max: Double
}
struct HeartRateData: Identifiable {
    let id = UUID()
    let timestamp: Date
    let rate: Double
    var color: Color
}
