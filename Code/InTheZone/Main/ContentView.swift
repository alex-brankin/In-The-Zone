//
//  InTheZone
//
//  Created by Alex Brankin on 02/03/2024.
//
//The ContentView in the SwiftUI application acts as the main navigational hub, organizing different functional
// views into a tabbed layout. It features four tabs:
//
// Workouts: Displays workout-related content in a FirstView, showing the user's workout sessions.
// Your Heart: Utilizes a SecondView to present heart rate information, linking to real-time data.
// Profile: Wrapped in a ThirdView, it provides user-specific details and settings through ProfileView.
// Settings: A straightforward SettingsView allows users to adjust application preferences.
//
// Each tab is represented by an icon and a label, and navigation is managed using NavigationStack for deeper
// hierarchical content management. The tabs facilitate easy access and organization of the app's features,
// enhancing user navigation and interaction with the app's diverse functionalities.

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
        ZStack(alignment: .topTrailing) {
            ProfileView()
                .environmentObject(UserData())

            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .navigationBarTitle("Profile")
            .padding(.trailing)
            .padding(.top, -20)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
