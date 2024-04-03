//
//  InTheZoneApp.swift
//  InTheZone
//
//  Created by Alex Brankin on 02/04/2024.
//

import SwiftUI

@main
struct InTheZone: App {
    @State private var isFirstLaunch = true

    var body: some Scene {
        WindowGroup {
            if isFirstLaunch {
                EKGLoadingView()
                    .preferredColorScheme(.dark)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            withAnimation {
                                self.isFirstLaunch = false
                            }
                        }
                    }
            } else {
                MainView()
            }
        }
    }
}

struct LaunchScreenView: View {
    var body: some View {
        // Your SwiftUI launch screen content here
        Text("Loading...")
            .font(.largeTitle)
            .foregroundColor(.white)
    }
}

struct MainView: View {
    var body: some View {
        // Your main app content here
        ContentView()
    }
}
