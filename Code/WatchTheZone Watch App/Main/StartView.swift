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
    @State private var showSummary = false
    @State private var isActive = false  // Controls navigation
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var selection: Tab = .zone
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selection){
                
                HistoryView().navigationBarTitle("History")
                    .tag(Tab.history)
                SelectZoneView().navigationBarHidden(true)
                    .tag(Tab.zone)
                SettingsView()
                    .tag(Tab.settings)
                
            }.navigationTitle(selection.title)
            .navigationBarBackButtonHidden(true)
            
        }.navigationBarBackButtonHidden(true)
    }
    
}

enum Tab {
    case history, zone, settings
    
    var title: String {
        switch self {
        case .history: return "History"
        case .zone: return ""
        case .settings: return "Settings"
        }
    }
}
struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
            .environmentObject(WorkoutManager())
    }
}


