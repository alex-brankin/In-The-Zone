//
//  InTheZoneApp.swift
//  InTheZone
//
//  Created by Alex Brankin on 02/04/2024.
//

import SwiftUI

@main
struct InTheZoneApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
