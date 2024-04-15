//
//  ContentView.swift
//  InTheZone
//
//  Created by Alex Brankin on 03/04/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 1
    @State private var currentBPM: Double = 0 // Define a State variable to hold the current BPM
    
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
                SecondView(currentBPM: $currentBPM) // Pass currentBPM as a binding
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
        }
        .accentColor(.red)
        .onAppear {
           
        }
    }
}

struct FirstView: View {
    var body: some View {
        WorkoutsView()
            .navigationTitle("Workouts")
            
            
    }
}

struct SecondView: View {
    @Binding var currentBPM: Double
    
    var body: some View {
        YourHeartView()
            
    }
}

struct ThirdView: View {
    var body: some View {
        ProfileView()
            
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
