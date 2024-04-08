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
            HKObjectType.quantityType(forIdentifier: .vo2Max)!
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

    
    // Fetching Step Count
    func fetchStepCount(completion: @escaping (Double?, Date?, Error?) -> Void) {
        let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount)!
        let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: stepCountType, predicate: predicate, limit: 1, sortDescriptors: nil) { (query, results, error) in
            guard let samples = results as? [HKQuantitySample], let sample = samples.first else {
                completion(nil, nil, error)
                return
            }
            
            let stepCount = sample.quantity.doubleValue(for: HKUnit.count())
            completion(stepCount, sample.startDate, nil)
        }
        
        healthStore.execute(query)
    }
    
    // Fetching Resting Heart Rate
    func fetchRestingHeartRate(completion: @escaping (Double?, Date?, Error?) -> Void) {
        let restingHeartRateType = HKObjectType.quantityType(forIdentifier: .restingHeartRate)!
        let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: restingHeartRateType, predicate: predicate, limit: 1, sortDescriptors: [sortDescriptor]) { (query, results, error) in
            guard let samples = results as? [HKQuantitySample], let sample = samples.first else {
                completion(nil, nil, error)
                return
            }
            
            let restingHeartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            completion(restingHeartRate, sample.startDate, nil)
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




    
    // Additional functions for fetching other health data types can be added here
    
}
