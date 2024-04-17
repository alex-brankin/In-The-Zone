import SwiftUI
import HealthKit

struct StepTestView: View {
    @State private var stepCount: Int = 0
    let healthStore = HKHealthStore()

    var body: some View {
        VStack {
            Text("Step Count")
                .font(.title)
                .padding()

            Text("\(stepCount)")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            Button("Refresh Step Count") {
                fetchStepCount()
            }
            .padding()
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(10)
        }
        .onAppear {
            fetchStepCount() // Fetch initially
            startFetchingStepCountEvery30Seconds()
        }
    }

    func startFetchingStepCountEvery30Seconds() {
        // Create a timer to fetch step count every 30 seconds
        Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { timer in
            fetchStepCount()
        }
    }

    func fetchStepCount() {
        guard let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            print("Step count type is not available.")
            return
        }

        // Define the start and end dates for the current day
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        // Create a predicate to query step count samples for the current day
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)

        let stepCountQuery = HKStatisticsQuery(quantityType: stepCountType,
                                               quantitySamplePredicate: predicate,
                                               options: .cumulativeSum) { (query, result, error) in
            if let result = result {
                DispatchQueue.main.async {
                    self.stepCount = Int(result.sumQuantity()?.doubleValue(for: .count()) ?? 0)
                }
            }
        }

        healthStore.execute(stepCountQuery)
    }
}

struct StepCountView_Previews: PreviewProvider {
    static var previews: some View {
        StepTestView()
    }
}
