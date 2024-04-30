//
//  InTheZone
//
//  Created by Alex Brankin on 02/03/2024.
//

import SwiftUI
import Charts

struct StepsChartView: View {
    let steps: [Step]
    @State var currentTab: String = "30 Days"
    
    var body: some View {
        VStack {
            Text("Step Counts")
                .font(.title)
                .fontWeight(.bold)
                .padding(.trailing, 200)
            HStack{
                Text("Views")
                    .fontWeight(.semibold)
                
                Picker("", selection: $currentTab) {
                    Text("7D")
                        .tag("7 Days")
                    Text("30D")
                        .tag("30 Days")
                    Text("1Y")
                        .tag("1 Year")
                }
                .pickerStyle(.segmented)
                .padding(.leading, 80)
            }
            Chart {
                ForEach(steps) { step in
                    BarMark(x: .value("Date", step.date, unit: .day), y: .value("Count", step.count))
                        .foregroundStyle(step.count < 10000 ? .red : .green) // Use dynamic color based on step count
                        
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 300)
            
            if steps.isEmpty {
                Text("No data available")
                    .foregroundColor(.secondary)
                    .padding(.vertical, 20)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(20)
        .shadow(radius: 5)
        .padding()
    }
}

struct StepsChartViewWrapper: View {
    @StateObject var viewModel = StepsChartViewModel()
    
    var body: some View {
        Group {
            if let steps = viewModel.steps {
                StepsChartView(steps: steps)
            } else if let error = viewModel.error {
                Text("Error: \(error.localizedDescription)")
                    .foregroundColor(.red)
            } else {
                ProgressView()
            }
        }
        .onAppear {
            viewModel.fetchStepCountForLast7Days()
        }
    }
}

class StepsChartViewModel: ObservableObject {
    @Published var steps: [Step]?
    @Published var error: Error?
    
    func fetchStepCountForLast7Days() {
        let healthKitManager = HealthKitManager()
        healthKitManager.fetchStepCountForLast7Days { counts, dates, error in
            DispatchQueue.main.async {
                if let counts = counts, let dates = dates {
                    let steps = zip(counts, dates).map { Step(count: Int($0), date: $1) }
                    self.steps = steps
                } else if let error = error {
                    self.error = error
                }
            }
        }
    }
}

struct StepsChartView_Previews: PreviewProvider {
    static var previews: some View {
        StepsChartViewWrapper()
    }
}
