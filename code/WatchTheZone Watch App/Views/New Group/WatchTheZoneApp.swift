//
//  WatchTheZoneApp.swift
//  WatchTheZone Watch App
//
//  Created by Alex Brankin on 03/04/2024.
//

import SwiftUI

@main
struct WatchTheZone: App {
    
    @StateObject var workoutManager = WorkoutManager()
    
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView{
                StartView()
            }
            .sheet(isPresented: $workoutManager.showingSummaryView) {
                SummaryView()
            }
            .environmentObject(workoutManager)
        }
    }
    }
    
