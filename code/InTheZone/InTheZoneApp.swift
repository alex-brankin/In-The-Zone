import SwiftUI
import HealthKit
import UIKit

// Define healthStore outside the @main struct
let healthStore = HKHealthStore()

@main
struct InTheZone: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var healthKitManager = HealthKitManager()
    @State private var isLoading = true

    var body: some Scene {
        WindowGroup {
            if isLoading {
                // Show the loading screen initially
                SplashScreen(isLoading: $isLoading)
            } else {
                    // If it's the first launch, show NewUserView
                    NewUserView()
                        .environmentObject(healthKitManager)
                        .onAppear {
                            // Set the first launch flag to false
                           
                        }
                }
            }
        }
    

    func requestHealthKitAuthorization() {
        // Call the requestAuthorization method of the HealthKitManager
        healthKitManager.requestAuthorization { success in
            if success {
                print("HealthKit authorization granted.")
            } else {
                print("HealthKit authorization failed.")
            }
        }
    }
}

// REMINDER TO PUT THIS BACK TO NORMAL - PORTRAIT CODE IS IN GITHUB
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            // Override point for customization after application launch.
            
            // Reset UserDefaults
            if let bundleIdentifier = Bundle.main.bundleIdentifier {
                UserDefaults.standard.removePersistentDomain(forName: bundleIdentifier)
            }
            
            return true
        }

        
    
}


struct SplashScreen: View {
    @Binding var isLoading: Bool

    var body: some View {
        // Your loading screen content here
        LoadingView()
            .onAppear {
                // Simulate loading time
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    // After loading, set isLoading to false
                    isLoading = false
                }
            }
    }
}

struct MainView: View {
    var body: some View {
        // Your main app content here
        ContentView()
    }
}

struct FirtTimer: View {
    @StateObject private var healthKitManager = HealthKitManager()

    var body: some View {
        NewUserView()
            .onAppear {
                // Request HealthKit authorization when the view appears
                InTheZone().requestHealthKitAuthorization()
            }
    }
}
