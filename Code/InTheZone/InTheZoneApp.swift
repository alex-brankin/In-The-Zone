import SwiftUI
import HealthKit

// Define healthStore outside the @main struct
let healthStore = HKHealthStore()

@main
struct InTheZone: App {
    @StateObject private var healthKitManager = HealthKitManager()
    @State private var isFirstLaunch = true

    var body: some Scene {
        WindowGroup {
            if isFirstLaunch {
                LaunchScreenView()
                    .preferredColorScheme(.dark)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            withAnimation {
                                self.isFirstLaunch = false
                                // Request authorization when the app launches
                                requestHealthKitAuthorization()
                            }
                        }
                    }
            } else {
                MainView()
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

struct LaunchScreenView: View {
    var body: some View {
        // Your SwiftUI launch screen content here
        Text("Loading...")
            .font(.largeTitle)
            .foregroundColor(.white)
    }
}

struct MainView: View {
    @StateObject private var healthKitManager = HealthKitManager()

    var body: some View {
        // Your main app content here
        ContentView()
            .environmentObject(healthKitManager)
    }
}



