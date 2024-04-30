//
//  InTheZone
//
//  Created by Alex Brankin on 02/03/2024.
//

import SwiftUI
import HealthKit
import Charts

struct WorkoutsView: View {
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
    @Environment(\.colorScheme) var colorScheme
    let workout: HKWorkout
    let healthManager = HealthKitManager()
    @State private var bpmData: [Double] = []
    @State private var error: Error?
    @State private var averageHeartRate: String = ""
    @State private var peakHeartRate: String = ""
    @State private var zonePercentages: [Double] = [60, 70, 80, 90, 100]
    @State private var zoneCounter: [ZoneCounter] = []
    @State private var targetZonePercentage: Double? = nil
    @State private var zoneDefinitions: [ZoneDefinition] = []
    @State private var zoneMinAndMax: [ZoneMinAndMax] = []
    @State private var heartRateData: [HeartRateData] = []
    @State private var heartRates: [Double] = []
    @State private var metadataValues: [String: Double] = [:]
    @State private var zoneCounts: [String: Int] = [
        "Zone 1": 0,
        "Zone 2": 0,
        "Zone 3": 0,
        "Zone 4": 0,
        "Zone 5": 0
    ]

    
    let maxHeartRate: Double = 200
    let zoneLabels: [String] = ["Zone 1", "Zone 2", "Zone 3", "Zone 4", "Zone 5"]
    let zoneColorMap: [String: Color] = [
           "Zone 1": .blue,
           "Zone 2": .green,
           "Zone 3": .yellow,
           "Zone 4": .orange,
           "Zone 5": .red
       ]

    let shortZoneColorMap: [String: Color] = [
           "z1": .blue,
           "z2": .green,
           "z3": .yellow,
           "z4": .orange,
           "z5": .red
       ]

    var body: some View {
        VStack {
            VStack {
                Text("Workout Details")
                    .font(.title)
                    .foregroundColor(.gray)
                    .padding(.bottom, -5)
                
                VStack(alignment: .leading) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Start")
                                .foregroundColor(.red)
                            Text("\(formattedStartTime(for: workout))")
                                .font(.title2)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

                        VStack(alignment: .leading) {
                            Text("End")
                                .foregroundColor(.red)
                            Text("\(formattedEndTime(for: workout))")
                                .font(.title2)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.vertical, 4)

                    HStack {
                        VStack(alignment: .leading) {
                            Text("Distance")
                                .foregroundColor(.red)
                            Text("\(String(format: "%.2f", Double(workout.totalDistance?.doubleValue(for: HKUnit.meter()) ?? 0) / 1000)) km")
                                .font(.title2)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

                        VStack(alignment: .leading) {
                            Text("Duration")
                                .foregroundColor(.red)
                            Text("\(formattedDuration(for: workout))")
                                .font(.title2)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.vertical, 4)

                    HStack {
                        VStack(alignment: .leading) {
                            Text("Avg Heart Rate")
                                .foregroundColor(.red)
                            Text("\(averageHeartRate)")
                                .font(.title2)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

                        VStack(alignment: .leading) {
                            Text("Max Heart Rate")
                                .foregroundColor(.red)
                            Text("\(peakHeartRate)")
                                .font(.title2)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.vertical, 4)

                    VStack(alignment: .leading) {
                        Text("Calories")
                            .foregroundColor(.red)
                        Text("\(Int(workout.totalEnergyBurned?.doubleValue(for: HKUnit.kilocalorie()) ?? 0))")
                            .font(.title2)
                    }
                    .padding(.vertical, 4)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                }
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding(.bottom, -10)
                .padding([.horizontal, .bottom])
            }
            .padding(.top, -30)
        }.padding(.top, -30)
        
        VStack {
            Text("Heart Rate").foregroundColor(.gray).padding(.bottom,-10)
            if !heartRates.isEmpty {
                // SwiftUI Line Chart
                Chart(heartRateData) { data in
                    LineMark(
                        x: .value("Time", data.timestamp),
                        y: .value("BPM", data.rate)
                    )
                    .foregroundStyle(colorScheme == .dark ? Color.gray : Color.gray.opacity(0.5))

                    
                    
                    ForEach(zoneDefinitions, id: \.max) { zone in
                        RuleMark(y: .value("Max", zone.max))
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                            .foregroundStyle(zone.color.opacity(0.75))
                    }
                }
                .frame(height: 160)
                .padding()
            } else if let error = error {
                Text("Error: \(error.localizedDescription)")
                    .foregroundColor(.red)
                    .padding()
            } else {
                // Display an empty state with a ProgressView
                ProgressView("Fetching BPM...")
                    .frame(width: 160, height: 160)
                    .padding()
            }
        }.background(Color(.secondarySystemBackground))
            .cornerRadius(10)
            .shadow(radius: 5)
            .padding(.bottom, -10)
            .padding([.horizontal, .bottom])
        
        VStack {
            let targetZoneIndex = Int(metadataValues["targetZone"] ?? 0.0)
            let targetZoneLabel = "Zone \(targetZoneIndex)"
            // Now fetch the color for this label from the zoneColorMap
            let targetZoneColor = zoneColorMap[targetZoneLabel] ?? .gray
            
            Text("Target: \(targetZoneLabel)")
                .font(.headline)
                .foregroundColor(targetZoneColor)
                .padding(.bottom, 5)
                .padding(.top, 10)
                .frame(maxWidth: .infinity, alignment: .center)

          
            HStack(alignment: .center, spacing: 20) {
                ZStack {
                    Chart(zoneCounter) { zone in
                        SectorMark(
                            angle: .value(
                                Text(verbatim: zone.zone),
                                zone.value
                            ),
                            innerRadius: .ratio(0.6)
                        )
                        .foregroundStyle(zoneColorMap[zone.zone] ?? .gray)
                    }
                    .frame(width: 160, height: 160)
                    
                    Text(String(format: "%.0f%%", targetZonePercentage ?? 0))
                        .font(.system(size: 30))
                        .fontWeight(.bold)
                        .foregroundColor(targetZoneColor)
                }.padding(.bottom, 10)

                VStack {
                    ForEach(zoneCounter, id: \.id) { zone in
                        HStack {
                            let shortKey = "z" + zone.zone.filter { $0.isNumber }
                            
                            Circle()
                                .fill(shortZoneColorMap[shortKey] ?? .gray)
                                .frame(width: 10, height: 10)
                            Text(zone.zone)
                                .font(.system(size: 16))
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding([.horizontal, .bottom])
        .onAppear{
            processWorkout()
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
        }
        
        
    }
            
    private func calculateTargetZonePercentage(){
        // Calculate the total value across all zones
        let total = zoneCounter.reduce(0.0) { $0 + $1.value }
        
        // Ensure there is a meaningful total to avoid division by zero
        if total == 0 {
            print("Total zone value is zero, cannot calculate percentages")
        }
        
        // Get the target zone index from metadata and construct its label
        let targetZoneIndex = Int(metadataValues["targetZone"] ?? 0.0)
        let targetZoneLabel = "Zone \(targetZoneIndex)"  // Example: "Zone 1"

        // Find the value for the target zone
        if let targetZone = zoneCounter.first(where: { $0.zone == targetZoneLabel }) {
            let targetZoneValue = targetZone.value
            let localTargetZonePercentage = (targetZoneValue / total) * 100
            
            // Return the calculated percentage
            targetZonePercentage = localTargetZonePercentage
        } else {
            print("Target zone not found in the data")

        }
    }
    
    private func formattedStartDate(for workout: HKWorkout) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        return dateFormatter.string(from: workout.startDate)
    }
    
    private func formattedStartTime(for workout: HKWorkout) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        return dateFormatter.string(from: workout.startDate)
    }
    
    private func formattedEndDate(for workout: HKWorkout) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm, MMMM d, yyyy"
        return dateFormatter.string(from: workout.endDate)
    }
    private func formattedEndTime(for workout: HKWorkout) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        return dateFormatter.string(from: workout.endDate)
    }
    
    private func formattedDuration(for workout: HKWorkout) -> String {
        let duration = Int(workout.duration)
        let hours = duration / 3600
        let minutes = (duration % 3600) / 60
        let seconds = duration % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    private func processWorkout() {
       
        print("Fetching Latest Workout")
        let brandPredicate = HKQuery.predicateForObjects(withMetadataKey: HKMetadataKeyWorkoutBrandName, allowedValues: ["InTheZone"])
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: HKObjectType.workoutType(), predicate: brandPredicate, limit: 1, sortDescriptors: [sortDescriptor]) { _, samples, error in
            guard let workouts = samples as? [HKWorkout], let latestWorkout1 = workouts.first else {
                print("Could not fetch workouts: \(String(describing: error))")
                return
            }
            let latestWorkout = workout
            
            let metadataKeys = [
                        "targetZone", "zone1Min", "zone1Max", "zone2Min", "zone2Max",
                        "zone3Min", "zone3Max", "zone4Min", "zone4Max", "zone5Min", "zone5Max"
                    ]

            var localMetadataValues: [String: Double] = [:]
            var localZoneDefinitions: [ZoneDefinition] = []
            let colors: [Color] = [.blue, .green, .yellow, .orange, .red]
            var colorIndex = 0

            // Check each key if it contains the expected metadata
            var doubleValue: Double = 0.0
            metadataKeys.forEach { key in
                print("Key : \(key)")
                print("Value : \(latestWorkout.metadata?[key] ?? "Missing")")
                if let stringValue = latestWorkout.metadata?[key] as? String {
                    doubleValue = Double(stringValue) ?? 0
                    localMetadataValues[key] = doubleValue
                    
                }
                    // Add to zoneDefinitions if the key ends with "Max"
                if key.contains("Min")  {
                        print("Key : \(key) - Value : \(doubleValue)")
                        let zoneDefinition = ZoneDefinition(max: doubleValue, color: colors[colorIndex % colors.count])
                        localZoneDefinitions.append(zoneDefinition)
                        colorIndex += 1 // increment color index to use next color
                    }
                    }


            DispatchQueue.main.async {
                self.metadataValues = localMetadataValues
                self.zoneDefinitions = localZoneDefinitions // Properly update the state
                self.fetchHeartRateData(for: latestWorkout)
            }
        }

        healthStore.execute(query)
    }

    private func fetchHeartRateData(for workout: HKWorkout) {
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else { return }
        let predicate = HKQuery.predicateForSamples(withStart: workout.startDate, end: workout.endDate, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        
        let query = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { _, samples, error in
            guard let samples = samples as? [HKQuantitySample] else { return }
            
            DispatchQueue.main.async {
                self.heartRateData = samples.map { HeartRateData(timestamp: $0.startDate, rate: $0.quantity.doubleValue(for: HKUnit(from: "count/min")), color: .gray) }
                self.heartRates = samples.map { $0.quantity.doubleValue(for: HKUnit(from: "count/min")) }
                self.categorizeHeartRates()
                self.calculateTargetZonePercentage()

            }
        }
        
        healthStore.execute(query)
    }
    
    private func colorForHeartRate() -> Color {
        var heartRateColor: Color = .gray
        for (index, rate) in heartRateData.enumerated() {
            
            for i in 0...4 {
                let minKey = "zone\(i+1)Min"
                let maxKey = "zone\(i+1)Max"
                
                if let min = metadataValues[minKey], let max = metadataValues[maxKey], rate.rate >= min && rate.rate <= max {
                    let zoneLabel = "Zone \(i+1)"
                    if let color = zoneColorMap[zoneLabel] {
                        var updatedRate = rate
                        updatedRate.color = color
                        heartRateColor = color
                        heartRateData[index] = updatedRate
                    }
                    break
                }
            }
        }
        return heartRateColor
    }
    private func categorizeHeartRates() {

        zoneCounts = zoneCounts.mapValues { _ in 0 }

        // Iterate through each heart rate and categorize it

        for rate in heartRates {
            for i in 0...4 {
                let minKey = "zone\(i+1)Min"
                let maxKey = "zone\(i+1)Max"

                if let min = metadataValues[minKey] as? Double, let max = metadataValues[maxKey] as? Double {
                    if rate >= min && rate <= max {
                        zoneCounts["Zone \(i+1)"]! += 1
                        break
                    }
                }
            }
        }

        // Convert zoneCounts to ZoneCounter objects and store in zoneCounter
        zoneCounter = zoneLabels.enumerated().compactMap { index, label in
            if let count = zoneCounts[label] {
                return ZoneCounter(zone: label, value: Double(count))
            }
            return nil
        }
        updateZonePercentages()
    }

    private func updateZonePercentages() {
        zonePercentages = zoneCounts.values.map(Double.init)  
    }
    
    // Function to calculate the percentage of max heart rate for each zone
    private func calculateZonePercentages() -> [Double] {
        let totalPercentage = zonePercentages.reduce(0, +)
        return zonePercentages.map { $0 / 100 * maxHeartRate / totalPercentage }
    }

    private func fetchBPMData() {
        healthManager.fetchBPMData { bpmData, error in
            if let error = error {
                self.error = error
            } else if let bpmData = bpmData {
                self.bpmData = bpmData
            }
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



}
struct WorkoutsView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutsView()
    }
}

