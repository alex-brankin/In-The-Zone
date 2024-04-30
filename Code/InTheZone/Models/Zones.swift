
//
//  InTheZone
//
//  Created by Alex Brankin on 02/03/2024.
//

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
