//
//  ContentView.swift
//  InTheZone
//
//  Created by Alex Brankin on 03/04/2024.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userData: UserData
    @State private var selectedTab = 1
    @State private var currentBPM: Double = 0
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                FirstView()
                    .navigationBarTitle("Workouts")
            }
            .tabItem {
                Image(systemName: "figure.run")
                Text("Workouts")
            }
            .tag(0)
            
            NavigationStack {
                SecondView(currentBPM: $currentBPM)
                    .navigationBarTitle("Your Heart")
            }
            .tabItem {
                Image(systemName: "heart.fill")
                Text("Your Heart")
            }
            .tag(1)
            
            NavigationStack {
                ThirdView()
                    .navigationBarTitle("Profile")
            }
            .tabItem {
                Image(systemName: "person.crop.circle")
                Text("Profile")
            }
            .tag(2)
            
            NavigationStack {
                SettingsView()
                    .navigationBarTitle("Settings")
            }
            .tabItem {
                Image(systemName: "gear")
                Text("Settings")
            }
            .tag(3)
        }
        .accentColor(.red)
        .onAppear {
           
        }
    }
}

struct FirstView: View {
    var body: some View {
        WorkoutsView()
    }
}

struct SecondView: View {
    @Binding var currentBPM: Double
    
    var body: some View {
        YourHeartView()
    }
}

struct ThirdView: View {
    @State private var showingSettings = false
    
    var body: some View {
            ProfileView()
                .environmentObject(UserData())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
