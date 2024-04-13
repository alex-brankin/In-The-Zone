import SwiftUI
import HealthKit

// Define healthStore outside the @main struct
let healthStore = HKHealthStore()

@main
struct InTheZone: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var healthKitManager = HealthKitManager()

    var body: some Scene {
        WindowGroup {
            // Check if it's the first launch
            if UserDefaults.standard.bool(forKey: "isFirstLaunch") {
                // If it's the first launch, show NewUserView
                NewUserView()
                    .environmentObject(healthKitManager)
                    .onAppear {
                        // Set the first launch flag to false
                        UserDefaults.standard.set(false, forKey: "isFirstLaunch")
                    }
            } else {
                // If it's not the first launch, show ContentView
                ContentView()
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

// Implement AppDelegate to handle orientation
class AppDelegate: NSObject, UIApplicationDelegate {
    internal func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait
    }
}

struct LaunchScreenView: View {
    var body: some View {
        // Your SwiftUI launch screen content here
        EKGLoadingView()
    }
}

struct MainView: View {
    @StateObject private var healthKitManager = HealthKitManager()

    var body: some View {
        // Your main app content here
        NewUserView()
            .environmentObject(healthKitManager)
    }
}
