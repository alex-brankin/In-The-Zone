//
//  WatchTheZone
//
//  Created by Alex Brankin on 13/03/2024.
//

import SwiftUI
import HealthKit

struct HistoryView: View {
    @State private var myWorkouts: [HKWorkout] = []
    let healthManager = HealthKitManager()
    

    var body: some View {
        List(myWorkouts, id: \.uuid) { workout in
            NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                HStack {
                    Image(systemName: imageForActivity(workout.workoutActivityType))
                        .font(.title)
                    VStack(alignment: .leading) {
                        Text("\(formattedActivity(for: workout))").font(.headline)
                        Text("Duration: \(formattedDuration(for: workout))").font(.subheadline)
                        Text("Date: \(formattedStartDate(for: workout))").font(.subheadline)
                    }
                }
            }
        }
        .onAppear {
            // Retrieve workouts when the view appears
            healthManager.retrieveWorkouts { workouts, error in
                if let error = error {
                    // Handle error
                    print("Error retrieving workouts: \(error.localizedDescription)")
                } else {
                    // Update the state with the retrieved workouts
                    if let workouts = workouts {
                        myWorkouts = workouts
                    }
                }
            }
        }
    }
    
    private func imageForActivity(_ activityType: HKWorkoutActivityType) -> String {
        switch activityType {
        case .running:
            return "figure.run"
        case .walking:
            return "figure.walk"
        case .cycling:
            return "bicycle"
        case .swimming:
            return "figure.swim"
        @unknown default:
            return "questionmark.circle"
        }
    }
    
    private func formattedDuration(for workout: HKWorkout) -> String {
        let duration = Int(workout.duration)
        let hours = duration / 3600
        let minutes = (duration % 3600) / 60
        let seconds = duration % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    private func formattedStartDate(for workout: HKWorkout) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM, yyyy  HH:mm"
        return dateFormatter.string(from: workout.startDate)
    }
    
    private func formattedActivity(for workout: HKWorkout) -> String {
        let activityType = workout.workoutActivityType
        let activityString: String
        switch activityType {
        case .running:
            activityString = "Running"
        case .walking:
            activityString = "Walking"
        case .cycling:
            activityString = "Cycling"
        case .swimming:
            activityString = "Swimming"
        @unknown default:
            activityString = "Unknown"
        }
        return activityString
    }
}

enum HeartRateQueryType {
    case average, peak
}

struct WorkoutDetailView: View {
    let workout: HKWorkout
    @State private var averageHeartRate: String = ""
    @State private var peakHeartRate: String = ""
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
    
    
    var body: some View {
        ScrollView{
            VStack(alignment: .leading) {
                Text("Workout Details")
                    .font(.system(size: 20))
                    .foregroundColor(.blue)
                
                Text("Distance: \(String(format: "%.2f", Double(workout.totalDistance?.doubleValue(for: HKUnit.meter()) ?? 0) / 1000)) km")
                Text("Start : \(formattedStartDate(for: workout))")
                    .font(.system(size: 14))
                Text("End : \(formattedEndDate(for: workout))")
                    .font(.system(size: 14))
                Text("Avg Heart Rate : \(averageHeartRate)")
                    .font(.system(size: 14))
                Text("Max Heart Rate : \(peakHeartRate)")
                    .font(.system(size: 14))
                Text("Calories: \(Int(workout.totalEnergyBurned?.doubleValue(for: HKUnit.kilocalorie()) ?? 0))")
                    .font(.system(size: 14))
                Spacer()
                
                Text("Target Zone : \(getZone(for: workout))").font(.system(size: 18))
                Text("Zone 1 : \(zone1Min) - \(zone1Max) bpm").foregroundColor(.blue).font(.system(size: 14))
                Text("Zone 2 : \(zone2Min) - \(zone2Max) bpm").foregroundColor(.green).font(.system(size: 14))
                Text("Zone 3 : \(zone3Min) - \(zone3Max) bpm").foregroundColor(.yellow).font(.system(size: 14))
                Text("Zone 4 : \(zone4Min) - \(zone4Max) bpm").foregroundColor(.orange).font(.system(size: 14))
                Text("Zone 5 : \(zone5Min) - \(zone5Max) bpm").foregroundColor(.red).font(.system(size: 14))
            }
            .padding()
            .onAppear {
                retrieveHeartRate(for: workout, queryType: HeartRateQueryType.average) { averageHeartRate in
                    if let averageHeartRate = averageHeartRate {
                        self.averageHeartRate = averageHeartRate
                    } else {
                        self.averageHeartRate = "Unknown"
                    }
                }
                retrieveHeartRate(for: workout, queryType: HeartRateQueryType.peak) { peakHeartRate in
                    if let peakHeartRate = peakHeartRate {
                        self.peakHeartRate = peakHeartRate
                    } else {
                        self.peakHeartRate = "Unknown"
                    }
                }
                
            }//.toolbar(.visible)
            
                .navigationBarBackButtonHidden(false)
        }
    }
    
    private func formattedStartDate(for workout: HKWorkout) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm, MMMM d, yyyy"
        return dateFormatter.string(from: workout.startDate)
    }
    
    private func formattedEndDate(for workout: HKWorkout) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm, MMMM d, yyyy"
        return dateFormatter.string(from: workout.endDate)
    }
    
    private func getZone(for workout: HKWorkout) -> String {
        if let metadata = workout.metadata {
            let zone = metadata["targetZone"] as? String ?? ""
            print("Zone: \(zone)")
            return zone
        } else {
            print("No metadata found")
            return "Unknown"
        }
    }
    enum HeartRateQueryType {
        case average, peak
    }
    func retrieveHeartRate(for workout: HKWorkout, queryType: HeartRateQueryType, completion: @escaping (String?) -> Void) {
        // Define the heart rate type
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            completion(nil)
            return
        }
        
        // Create a predicate to query heart rate samples for the workout's time interval
        let predicate = HKQuery.predicateForSamples(withStart: workout.startDate, end: workout.endDate, options: .strictStartDate)
        
        // Determine the options based on the query type
        var options: HKStatisticsOptions
        switch queryType {
        case .average:
            options = .discreteAverage
        case .peak:
            options = .discreteMax
        }
        
        // Create a query to retrieve heart rate samples
        let query = HKStatisticsQuery(quantityType: heartRateType, quantitySamplePredicate: predicate, options: options) { (_, result, error) in
            guard let result = result else {
                completion(nil)
                return
            }
            
            // Get the heart rate value based on the query type
            var heartRateValue: Double?
            switch queryType {
            case .average:
                heartRateValue = result.averageQuantity()?.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
            case .peak:
                heartRateValue = result.maximumQuantity()?.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
            }
            
            // Format the heart rate value
            if let heartRateValue = heartRateValue {
                let formattedHeartRate = String(format: "%.0f bpm", heartRateValue)
                completion(formattedHeartRate)
            } else {
                completion(nil)
            }
        }
        
        // Execute the query
        HKHealthStore().execute(query)
    }
    
    
    // Function to retrieve heart rate samples for the workout
    private func getHeartRateSamples(for workout: HKWorkout, completion: @escaping ([HKQuantitySample]?) -> Void) {
        // Retrieve heart rate samples within the workout duration
        let predicate = HKQuery.predicateForSamples(withStart: workout.startDate, end: workout.endDate, options: .strictStartDate)
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let query = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
            guard let samples = samples as? [HKQuantitySample], error == nil else {
                completion(nil) // Call completion with nil if there's an error
                return
            }
            completion(samples) // Call completion with the retrieved samples
        }
        HKHealthStore().execute(query)
    }
    
    
    struct HistoryView_Previews: PreviewProvider {
        static var previews: some View {
            HistoryView()
        }
    }
    
}
