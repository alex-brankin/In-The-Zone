//
//  InTheZone
//
//  Created by Alex Brankin on 02/03/2024.
//

import SwiftUI

struct StepListView: View {
    @State private var stepCounts: [Double] = []
    @State private var dates: [Date] = []
    @State private var error: Error?
    let goalSteps: Int
    
    var body: some View {
        VStack {
            if !stepCounts.isEmpty {
                List(0..<min(stepCounts.count, dates.count), id: \.self) { index in
                    let stepCount = stepCounts[index]
                    let date = dates[index]
                    StepRow(stepCount: stepCount, date: date, goalSteps: goalSteps)
                        .padding(.vertical, 8)
                }
                .listStyle(PlainListStyle())
            } else if let error = error {
                Text("Error: \(error.localizedDescription)")
                    .foregroundColor(.red)
            } else {
                ProgressView()
            }
        }
        .padding(.horizontal)
        .onAppear {
            let healthKitManager = HealthKitManager()
            healthKitManager.fetchStepCountForLast7Days { counts, dates, error in
                if let counts = counts, let dates = dates {
                    let sortedData = zip(counts, dates).sorted(by: { $0.1 > $1.1 })
                    self.stepCounts = sortedData.map { $0.0 }
                    self.dates = sortedData.map { $0.1 }
                } else if let error = error {
                    self.error = error
                }
            }
        }
    }
}


struct StepRow: View {
    let stepCount: Double
    let date: Date
    let goalSteps: Int
    
    var body: some View {
        HStack {
            Circle()
                .frame(width: 10, height: 10)
                .foregroundStyle(isUnderGoal(stepCount, goalSteps: goalSteps) ? .red : .green)
            Text("\(Int(stepCount))")
                .font(.headline)
            Spacer()
            Text(date.formatted(date: .abbreviated, time: .omitted))
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

struct StepListView_Previews: PreviewProvider {
    static var previews: some View {
        StepListView(goalSteps: 10000)
    }
}

func isUnderGoal(_ count: Double, goalSteps: Int) -> Bool {
    return count < Double(goalSteps)
}

