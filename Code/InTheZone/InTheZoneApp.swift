import SwiftUI
import HealthKit

// Define healthStore outside the @main struct
let healthStore = HKHealthStore()

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
        // Check if HealthKit is available on this device
        if !HKHealthStore.isHealthDataAvailable() {
            print("HealthKit is not available on this device.")
            return
        }

        // Define the types of health data to be read from HealthKit
        let healthKitTypesToRead: Set<HKObjectType> = [
            HKObjectType.workoutType(),
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            // Add other types you need access to
        ]

        // Request authorization to access health data
        healthStore.requestAuthorization(toShare: nil, read: healthKitTypesToRead) { (success, error) in
            if success {
                print("HealthKit authorization granted.")
            } else {
                if let error = error {
                    print("HealthKit authorization failed with error: \(error.localizedDescription)")
                } else {
                    print("HealthKit authorization failed.")
                }
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
