//
//  ContentView.swift
//  InTheZone
//
//  Created by Alex Brankin on 03/04/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 1
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                FirstView()
                    .navigationBarTitle("Workouts")
            }
            .tabItem {
                Image(systemName: "figure.run")
                Text("Workouts")
            }
            .tag(0)
            
            NavigationView {
                SecondView()
                    .navigationBarTitle("Your Heart")
            }
            .tabItem {
                Image(systemName: "heart.fill")
                Text("Your Heart")
            }
            .tag(1)
            
            NavigationView {
                ThirdView()
                    .navigationBarTitle("Settings")
            }
            .tabItem {
                Image(systemName: "person.crop.circle")
                Text("Profile")
            }
            .tag(2)
        }
        .onAppear {
            UITabBar.appearance().barTintColor = .white
        }
    }
}

struct FirstView: View {
    var body: some View {
        WorkoutsView()
            .font(.largeTitle)
    }
}

struct SecondView: View {
    var body: some View {
        YourHeartView()
            .font(.largeTitle)
    }
}

struct ThirdView: View {
    var body: some View {
        ProfileView()
            .font(.largeTitle)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

