//
//  StartView.swift
//  WatchTheZone Watch App
//
//  Created by Alex Brankin on 02/04/2024.
//
// The StartView in the WatchTheZone Watch App provides a central navigation interface, offering a
// TabView where users can switch between viewing workout history, selecting workout zones, and
// adjusting settings. Each tab is encapsulated within a NavigationStack, enhancing the navigational
// experience with appropriate titles set for each view, except for the zone selection where the
// navigation bar is hidden. On appearance, the app initiates a request for HealthKit authorization
// via HealthStoreManager, ensuring necessary permissions are granted for accessing health data.

import SwiftUI
import HealthKit

struct StartView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var selection: Tab = .zone
    
    enum Tab {
        case history, zone, settings
    }
    
    var body: some View {
        TabView(selection: $selection){
            NavigationStack {
                HistoryView().navigationBarTitle("History")
            }
            .tag(Tab.history)
            
            NavigationStack {
                SelectZoneView().navigationBarHidden(true)
            }
            .tag(Tab.zone)
            
            NavigationStack {
                SettingsView().navigationBarTitle("Settings")
            }
            .tag(Tab.settings)
        }
        .navigationBarBackButtonHidden(false)
        .onAppear {
            HealthStoreManager.shared.requestAuthorization()
                }
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
            .environmentObject(WorkoutManager())
    }
}
