//
//  ContentView.swift
//  WatchTheZone Watch App
//
//  Created by Alex Brankin on 02/04/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var isRecording = false
    @State private var selectedTab = 1
    @StateObject var settings = SettingsModel()

    var body: some View {
        TabView(selection: $selectedTab) {
            PreviousWorkoutsView(previousWorkouts: previousWorkouts)
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Previous Workouts")
                }
                .tag(0)
            
            StartExerciseView(isRecording: $isRecording)
                .tabItem {
                    Image(systemName: "play.circle")
                    Text("Start Exercise")
                }
                .tag(1)
            
            SettingsView(settings: settings)
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(2)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
