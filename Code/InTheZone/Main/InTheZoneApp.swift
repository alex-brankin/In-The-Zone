//
//  InTheZone
//
//  Created by Alex Brankin on 02/03/2024.
//
// The InTheZone SwiftUI application interfaces with HealthKit and WatchConnectivity to manage fitness data. It
// initializes by setting up a recurring task to sync workout zone settings to a paired Apple Watch via a
// SyncService. The app manages workout zones using @AppStorage for persistence, automatically updating the watch
// whenever these settings change. It features a main view that loads conditionally based on whether the user data
// indicates a new or returning user, and it handles HealthKit authorization to access fitness data securely.

import SwiftUI
import HealthKit
import WatchConnectivity

let healthStore = HKHealthStore()

@main
struct InTheZone: App {
    
    @StateObject private var notificationManager = NotificationManager()

    @AppStorage("zone1Min") private var zone1Min = ""
    @AppStorage("zone1Max") private var zone1Max = ""
    @AppStorage("zone2Min") private var zone2Min = ""
    @AppStorage("zone2Max") private var zone2Max = ""
    @AppStorage("zone3Min") private var zone3Min = ""
    @AppStorage("zone3Max") private var zone3Max = ""
    @AppStorage("zone4Min") private var zone4Min = ""
    @AppStorage("zone4Max") private var zone4Max = ""
    @AppStorage("zone5Min") private var zone5Min = ""
    @AppStorage("zone5Max") private var zone5Max = ""
    
    private var syncService = SyncService()
    
    init() {
        startSendingSettingToWatch()
    }
    
    func startSendingSettingToWatch() {
        // Create a timer that repeats every 60 seconds
        let timer = Timer(timeInterval: 10, repeats: true) { _ in
            sendSettingToWatch()
        }
        
        // Schedule the timer on a background thread
        DispatchQueue.global().async {
            RunLoop.current.add(timer, forMode: .default)
            RunLoop.current.run()
        }
    }
    
    func sendSettingToWatch() {
        let latestZone1Min = zone1Min
        let latestZone1Max = zone1Max
        let latestZone2Min = zone2Min
        let latestZone2Max = zone2Max
        let latestZone3Min = zone3Min
        let latestZone3Max = zone3Max
        let latestZone4Min = zone4Min
        let latestZone4Max = zone4Max
        let latestZone5Min = zone5Min
        let latestZone5Max = zone5Max
        
        print("Sending to Watch")
        
        // Send the latest value to the watch
        syncService.sendMessage("zone1Min", latestZone1Min) { error in
            print("Error sending message: \(error.localizedDescription)")
        }
        syncService.sendMessage("zone1Max", latestZone1Max) { error in
            print("Error sending message: \(error.localizedDescription)")
        }
        syncService.sendMessage("zone2Min", latestZone2Min) { error in
            print("Error sending message: \(error.localizedDescription)")
        }
        syncService.sendMessage("zone2Max", latestZone2Max) { error in
            print("Error sending message: \(error.localizedDescription)")
        }
        syncService.sendMessage("zone3Min", latestZone3Min) { error in
            print("Error sending message: \(error.localizedDescription)")
        }
        syncService.sendMessage("zone3Max", latestZone3Max) { error in
            print("Error sending message: \(error.localizedDescription)")
        }
        syncService.sendMessage("zone4Min", latestZone4Min) { error in
            print("Error sending message: \(error.localizedDescription)")
        }
        syncService.sendMessage("zone4Max", latestZone4Max) { error in
            print("Error sending message: \(error.localizedDescription)")
        }
        syncService.sendMessage("zone5Min", latestZone5Min) { error in
            print("Error sending message: \(error.localizedDescription)")
        }
        syncService.sendMessage("zone5Max", latestZone5Max) { error in
            print("Error sending message: \(error.localizedDescription)")
        }
    }
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var healthKitManager = HealthKitManager()
    @State private var isLoading = true

    var body: some Scene {
        WindowGroup {
            if isLoading {
                SplashScreen(isLoading: $isLoading)
            } else {
                let userData = UserData()
                let isNewUser = userData.calculatedAge == 0 && userData.name.isEmpty
                if isNewUser {
                    NewUserView()
                        .environmentObject(healthKitManager)
                } else {
                    ContentView()
                }
            }
        }
    }


    func requestHealthKitAuthorization() {
        healthKitManager.requestAuthorization { success in
            if success {
                print("HealthKit authorization granted.")
            } else {
                print("HealthKit authorization failed.")
            }
        }
    }
}


class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            return true
        }
}

struct SplashScreen: View {
    @Binding var isLoading: Bool

    var body: some View {
        LoadingView()
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    isLoading = false
                }
            }
    }
}

struct MainView: View {
    var body: some View {
        ContentView()
    }
}

struct FirtTimer: View {
    @StateObject private var healthKitManager = HealthKitManager()

    var body: some View {
        NewUserView()
            .onAppear {
                InTheZone().requestHealthKitAuthorization()
            }
    }
}
