//
//  WatchTheZone
//
//  Created by Alex Brankin on 13/03/2024.
//

import Foundation
import HealthKit

class WorkoutManager: NSObject, ObservableObject {
    
    var selectedWorkout: HKWorkoutActivityType?
    {
        didSet {
            guard let selectedWorkout = selectedWorkout else { return }
            startWorkout(workoutType: selectedWorkout)
        }
    }
    var targetZone: Int = 0
    
    @Published var showingSummaryView: Bool = false {
        didSet {
            // Sheet dismissed
            if showingSummaryView == false {
                resetWorkout()
                }
        }
    }
    
    var zone1Min: String {
        get {
            UserDefaults.standard.string(forKey: "zone1Min") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "zone1Min")
        }
    }
    
    var zone1Max: String {
        get {
            UserDefaults.standard.string(forKey: "zone1Max") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "zone1Max")
        }
    }
    
    var zone2Min: String {
        get {
            UserDefaults.standard.string(forKey: "zone2Min") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "zone2Min")
        }
    }
    
    var zone2Max: String {
        get {
            UserDefaults.standard.string(forKey: "zone2Max") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "zone2Max")
        }
    }
    
    var zone3Min: String {
        get {
            UserDefaults.standard.string(forKey: "zone3Min") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "zone3Min")
        }
    }
    
    var zone3Max: String {
        get {
            UserDefaults.standard.string(forKey: "zone3Max") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "zone3Max")
        }
    }
    
    var zone4Min: String {
        get {
            UserDefaults.standard.string(forKey: "zone4Min") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "zone4Min")
        }
    }
    
    var zone4Max: String {
        get {
            UserDefaults.standard.string(forKey: "zone4Max") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "zone4Max")
        }
    }
    
    var zone5Min: String {
        get {
            UserDefaults.standard.string(forKey: "zone5Min") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "zone5Min")
        }
    }
    
    var zone5Max: String {
        get {
            UserDefaults.standard.string(forKey: "zone5Max") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "zone5Max")
        }
    }
    

    
    let healthStore = HKHealthStore()
    var session: HKWorkoutSession?
    var builder: HKLiveWorkoutBuilder?
    
    func startWorkout(workoutType: HKWorkoutActivityType) {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = workoutType
        configuration.locationType = .outdoor

        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            builder = session?.associatedWorkoutBuilder()
        } catch {
            // Handle any exceptions.
            return
        }

        builder?.dataSource = HKLiveWorkoutDataSource(
            healthStore: healthStore,
            workoutConfiguration: configuration
        )

        session?.delegate = self
        builder?.delegate = self
        
        // Start the workout session and begin data collection.
        let startDate = Date()
        session?.startActivity(with: startDate)
        builder?.beginCollection(withStart: startDate) { (success, error) in
            // The workout has started.
            
        }
        if let builder = self.builder {
            let brand = "InTheZone"
            let metadata: [String: String] = [
                HKMetadataKeyWorkoutBrandName: brand,
                "targetZone": String(targetZone),
                "zone1Min": String(zone1Min),
                "zone1Max": String(zone1Max),
                "zone2Min": String(zone2Min),
                "zone2Max": String(zone2Max),
                "zone3Min": String(zone3Min),
                "zone3Max": String(zone3Max),
                "zone4Min": String(zone4Min),
                "zone4Max": String(zone4Max),
                "zone5Min": String(zone5Min),
                "zone5Max": String(zone5Max)
            ]
            builder.addMetadata(metadata) { (success, error) in
                print(success ? "Success saving metadata" : error as Any)
            }
        } else {
            print("Builder is nil, unable to add metadata.")
        }
       
    }
    
    // Request authorization to access HealthKit.
    func requestAuthorization() {
        // The quantity type to write to the health store.
        let typesToShare: Set = [
            HKQuantityType.workoutType()
        ]

        // The quantity types to read from the health store.
        let typesToRead: Set = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKQuantityType.quantityType(forIdentifier: .distanceCycling)!,
            HKObjectType.activitySummaryType()
        ]
        
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
            if success {
                // Authorization granted, do nothing
            } else {
                // Authorization denied or error occurred
                if let error = error {
                    print("Authorization failed: \(error.localizedDescription)")
                } else {
                    print("Authorization denied")
                }
            }
        }
    }


    
    // State Control

    // The workout session state.
    @Published var running = false

    func pause() {
        session?.pause()
    }

    func resume() {
        session?.resume()
    }

    func togglePause() {
        if running == true {
            pause()
        } else {
            resume()
        }
    }

    func endWorkout() {
        session?.end()
        showingSummaryView = true
    }
    // Workout Metrics
    @Published var averageHeartRate: Double = 0
    @Published var heartRate: Double = 0
    @Published var activeEnergy: Double = 0
    @Published var distance: Double = 0
    @Published var workout: HKWorkout?
    
    func updateForStatistics(_ statistics: HKStatistics?) {
        guard let statistics = statistics else { return }

        DispatchQueue.main.async {
            switch statistics.quantityType {
            case HKQuantityType.quantityType(forIdentifier: .heartRate):
                let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
                self.heartRate = statistics.mostRecentQuantity()?.doubleValue(for: heartRateUnit) ?? 0
                self.averageHeartRate = statistics.averageQuantity()?.doubleValue(for: heartRateUnit) ?? 0
            case HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned):
                let energyUnit = HKUnit.kilocalorie()
                self.activeEnergy = statistics.sumQuantity()?.doubleValue(for: energyUnit) ?? 0
            case HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning), HKQuantityType.quantityType(forIdentifier: .distanceCycling):
                let meterUnit = HKUnit.meter()
                self.distance = statistics.sumQuantity()?.doubleValue(for: meterUnit) ?? 0
            default:
                return
            }
        }
    }
    
    func resetWorkout() {
        selectedWorkout = nil
        builder = nil
        session = nil
        workout = nil
        activeEnergy = 0
        averageHeartRate = 0
        heartRate = 0
        distance = 0
    }

}



// HKWorkoutSessionDelegate
extension WorkoutManager: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession,
                        didChangeTo toState: HKWorkoutSessionState,
                        from fromState: HKWorkoutSessionState,
                        date: Date) {
        DispatchQueue.main.async {
            self.running = toState == .running
            print("WM Status : " + String(self.running))
        }

        // Wait for the session to transition states before ending the builder.
        if toState == .ended {
            builder?.endCollection(withEnd: date) { (success, error) in
                self.builder?.finishWorkout { (workout, error) in
                    DispatchQueue.main.async {
                        self.workout = workout
                    }
                }
            }
        }
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {

    }
}
// HKLiveWorkoutBuilderDelegate
extension WorkoutManager: HKLiveWorkoutBuilderDelegate {
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
    }

    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else { return }

            let statistics = workoutBuilder.statistics(for: quantityType)

            // Update the published values.
            updateForStatistics(statistics)
        }
    }
}
