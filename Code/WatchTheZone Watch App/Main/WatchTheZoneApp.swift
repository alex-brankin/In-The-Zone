//
//  WatchTheZone
//
//  Created by Alex Brankin on 13/03/2024.
//
// This WatchTheZone SwiftUI application serves as the entry point to the app, initializing key
// components like WorkoutManager and WorkUIManager as state objects. It sets default heart rate
// zone values in UserDefaults upon startup if they are not already set, ensuring the app has
// necessary data for zone calculations. 

import SwiftUI

@main
struct WatchTheZone: App {
    
    @WKExtensionDelegateAdaptor(ExtensionDelegate.self) var extensionDelegate

    @StateObject var workoutManager = WorkoutManager()
    @StateObject var workoutUIManager = WorkoutUIManager()
    
    @SceneBuilder var body: some Scene {
        WindowGroup {

                StartView()

            .onAppear {
                print("checking User Defaults")
                if UserDefaults.standard.string(forKey: "zone1Min") == "" {
                    UserDefaults.standard.set("0", forKey: "zone1Min")
                    print("No value for Zone1Min")
                }
                if UserDefaults.standard.string(forKey: "zone1Max") == "" {
                    UserDefaults.standard.set("132", forKey: "zone1Max")
                }
                if UserDefaults.standard.string(forKey: "zone2Min") == "" {
                    UserDefaults.standard.set("133", forKey: "zone2Min")
                }
                if UserDefaults.standard.string(forKey: "zone2Max") == "" {
                    UserDefaults.standard.set("145", forKey: "zone2Max")
                }
                if UserDefaults.standard.string(forKey: "zone3Min") == "" {
                    UserDefaults.standard.set("146", forKey: "zone3Min")
                }
                if UserDefaults.standard.string(forKey: "zone3Max") == "" {
                    UserDefaults.standard.set("157", forKey: "zone3Max")
                }
                if UserDefaults.standard.string(forKey: "zone4Min") == "" {
                    UserDefaults.standard.set("158", forKey: "zone4Min")
                }
                if UserDefaults.standard.string(forKey: "zone4Max") == "" {
                    UserDefaults.standard.set("168", forKey: "zone4Max")
                }
                if UserDefaults.standard.string(forKey: "zone5Min") == "" {
                    UserDefaults.standard.set("169", forKey: "zone5Min")
                }
                if UserDefaults.standard.string(forKey: "zone5Max") == "" {
                    UserDefaults.standard.set("180", forKey: "zone5Max")
                }
            }
            .environmentObject(workoutManager)
            .environmentObject(workoutUIManager)
        }
    }
    }
    
