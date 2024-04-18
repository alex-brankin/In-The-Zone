import HealthKit

class HealthKitManager: NSObject, ObservableObject {
    let healthStore = HKHealthStore()

    // MARK: - Authorization
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device.")
            completion(false)
            return
        }

        let healthKitTypesToRead: Set<HKObjectType> = [
            HKObjectType.workoutType(),
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
            HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
            HKObjectType.quantityType(forIdentifier: .vo2Max)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .basalEnergyBurned)!
        ]



        let healthKitTypesToWrite: Set<HKSampleType> = []

        healthStore.requestAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypesToRead) { (success, error) in
            if success {
                print("HealthKit authorization granted.")
            } else {
                if let error = error {
                    print("HealthKit authorization failed with error: \(error.localizedDescription)")
                } else {
                    print("HealthKit authorization failed.")
                }
            }
            completion(success)
        }
    }

    // MARK: - Fetching Health Data
    
    func fetchMostRecentHeartRate(completion: @escaping (Double?, Date?, Error?) -> Void) {
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictEndDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: 1, sortDescriptors: [sortDescriptor]) { (query, results, error) in
            guard let samples = results as? [HKQuantitySample], let sample = samples.first else {
                completion(nil, nil, error)
                return
            }
            
            let heartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            completion(heartRate, sample.startDate, nil)
        }
        
        healthStore.execute(query)
    }

    func fetchBPMData(completion: @escaping ([Double]?, Error?) -> Void) {
        // Define the health store
        let healthStore = HKHealthStore()
        
        // Define the BPM type
        let bpmType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        
        // Define the predicate to get data for the current day
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        // Define the sort descriptor
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        
        // Define the BPM query
        let query = HKSampleQuery(sampleType: bpmType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { query, results, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            // Extract BPM values from the results
            guard let samples = results as? [HKQuantitySample] else {
                completion(nil, NSError(domain: "com.yourapp.error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to cast samples"]))
                return
            }
            
            let bpmData = samples.map { sample in
                return sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
            }
            
            completion(bpmData, nil)
        }
        
        // Execute the query
        healthStore.execute(query)
    }


    func startHeartRateObserver(completion: @escaping (Double?, Error?) -> Void) {
        let sampleType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let query = HKObserverQuery(sampleType: sampleType, predicate: nil) { (query, completionHandler, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            self.fetchMostRecentHeartRate { heartRate, _, error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                completion(heartRate, nil)
            }
            completionHandler()
        }
        
        healthStore.execute(query)
    }

    // Fetching Average Heart Rate for the Day
    func fetchAverageHeartRateForDay(completion: @escaping (Double?, Error?) -> Void) {
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let statisticsOptions: HKStatisticsOptions = [.discreteAverage]
        
        let query = HKStatisticsQuery(quantityType: heartRateType, quantitySamplePredicate: predicate, options: statisticsOptions) { (_, result, error) in
            guard let result = result else {
                completion(nil, error)
                return
            }
            
            let averageHeartRate = result.averageQuantity()?.doubleValue(for: HKUnit(from: "count/min")) ?? 0
            completion(averageHeartRate, nil)
        }
        
        healthStore.execute(query)
    }

    // Fetching Maximum Heart Rate for the Day
    func fetchMaximumHeartRateForDay(completion: @escaping (Double?, Error?) -> Void) {
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let statisticsOptions: HKStatisticsOptions = [.discreteMax]
        
        let query = HKStatisticsQuery(quantityType: heartRateType, quantitySamplePredicate: predicate, options: statisticsOptions) { (_, result, error) in
            guard let result = result else {
                completion(nil, error)
                return
            }
            
            let maximumHeartRate = result.maximumQuantity()?.doubleValue(for: HKUnit(from: "count/min")) ?? 0
            completion(maximumHeartRate, nil)
        }
        
        healthStore.execute(query)
    }
    
    
    // Fetching Step Count
    func fetchStepCount(completion: @escaping (Double?, Date?, Error?) -> Void) {
        guard let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            completion(nil, nil, nil)
            return
        }

        // Define the start and end dates for the current day
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: stepCountType,
                                       quantitySamplePredicate: predicate,
                                       options: .cumulativeSum) { (query, result, error) in
            if let result = result {
                DispatchQueue.main.async {
                    let stepCount = result.sumQuantity()?.doubleValue(for: .count()) ?? 0
                    completion(stepCount, now, nil)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil, nil, error)
                }
                if let error = error {
                    print("Error fetching step count: \(error.localizedDescription)")
                }
            }
        }

        healthStore.execute(query)
    }

    func fetchRestingHeartRateForToday(completion: @escaping (Double?, Error?) -> Void) {
        let restingHeartRateType = HKObjectType.quantityType(forIdentifier: .restingHeartRate)!
        
        // Calculate the start date (today) and the end date (tomorrow)
        let endDate = Date()
        let startDate = Calendar.current.startOfDay(for: endDate)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endOfDay, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: restingHeartRateType, predicate: predicate, limit: 1, sortDescriptors: [sortDescriptor]) { (query, results, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let samples = results as? [HKQuantitySample], let sample = samples.first else {
                completion(nil, nil)
                return
            }
            
            let restingHeartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            completion(restingHeartRate, nil)
        }
        
        healthStore.execute(query)
    }


    
    
    // Fetching Resting Heart Rate
    func fetchRestingHeartRate(forLastDays days: Int, completion: @escaping ([Double]?, [Date]?, Error?) -> Void) {
        let restingHeartRateType = HKObjectType.quantityType(forIdentifier: .restingHeartRate)!
        
        // Calculate the start date (7 days ago) and the end date (now)
        let endDate = Date()
        guard let startDate = Calendar.current.date(byAdding: .day, value: -days, to: endDate) else {
            completion(nil, nil, NSError(domain: "com.yourapp.error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to calculate start date"]))
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        
        let query = HKSampleQuery(sampleType: restingHeartRateType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { (query, results, error) in
            guard let samples = results as? [HKQuantitySample] else {
                completion(nil, nil, error)
                return
            }
            
            // Extract resting heart rate values and corresponding dates
            var restingHeartRates: [Double] = []
            var dates: [Date] = []
            for sample in samples {
                let heartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                restingHeartRates.append(heartRate)
                dates.append(sample.startDate)
            }
            
            completion(restingHeartRates, dates, nil)
        }
        
        healthStore.execute(query)
    }


    
    // Fetching Heart Rate Variability
    func fetchHeartRateVariability(completion: @escaping (Double?, Date?, Error?) -> Void) {
        let hrvType = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
        let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: hrvType, predicate: predicate, limit: 1, sortDescriptors: [sortDescriptor]) { (query, results, error) in
            guard let samples = results as? [HKQuantitySample], let sample = samples.first else {
                completion(nil, nil, error)
                return
            }
            
            let hrv = sample.quantity.doubleValue(for: HKUnit.secondUnit(with: .milli))
            completion(hrv, sample.startDate, nil)
        }
        
        healthStore.execute(query)
    }

    
    // Fetching VO2 Max
    func fetchVO2Max(completion: @escaping (Double?, Date?, Error?) -> Void) {
        let vo2MaxType = HKObjectType.quantityType(forIdentifier: .vo2Max)!
        let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: vo2MaxType, predicate: predicate, limit: 1, sortDescriptors: [sortDescriptor]) { (query, results, error) in
            guard let samples = results as? [HKQuantitySample], let sample = samples.first else {
                completion(nil, nil, error)
                return
            }
            
            let vo2Max = sample.quantity.doubleValue(for: HKUnit(from: "ml/(kg*min)"))
            completion(vo2Max, sample.startDate, nil)
        }
        
        healthStore.execute(query)
    }
    
    // Fetching Distance for Walking + Running
    func fetchWalkingRunningDistance(completion: @escaping (Double?, Error?) -> Void) {
        let distanceType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (_, result, error) in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(nil, error)
                return
            }

            let distance = sum.doubleValue(for: HKUnit.meter())
            completion(distance, nil)
        }

        healthStore.execute(query)
    }

    // Fetching calories burned
    func fetchActiveEnergy(completion: @escaping (Double?, Error?) -> Void) {
        let activeEnergyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: activeEnergyType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (_, result, error) in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(nil, error)
                return
            }

            let activeEnergy = sum.doubleValue(for: HKUnit.kilocalorie())
            completion(activeEnergy, nil)
        }

        healthStore.execute(query)
    }

    // Fetching BMR
    func fetchBMR(completion: @escaping (Double?, Error?) -> Void) {
        let bmrType = HKObjectType.quantityType(forIdentifier: .basalEnergyBurned)!
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: bmrType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (_, result, error) in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(nil, error)
                return
            }

            let bmr = sum.doubleValue(for: HKUnit.kilocalorie())
            completion(bmr, nil)
        }

        healthStore.execute(query)
    }



    // Additional functions for fetching other health data types can be added here
    
}
