//
//  StartView.swift
//  WatchTheZone Watch App
//
//  Created by Alex Brankin on 02/04/2024.
//

import SwiftUI

struct StartView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var selection: Tab = .zone
    
    enum Tab {
        case history, zone, settings
    }
    
    var body: some View {
        TabView(selection: $selection){
            NavigationStack {
                HistoryView().navigationBarTitle("History") // Set the title here
            }
            .tag(Tab.history)
            
            NavigationStack {
                SelectZoneView().navigationBarHidden(true) // Set the title here
            }
            .tag(Tab.zone)
            
            NavigationStack {
                SettingsView().navigationBarTitle("Settings") // Set the title here
            }
            .tag(Tab.settings)
        }
        .navigationBarBackButtonHidden(false)
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
            .environmentObject(WorkoutManager())
    }
}
