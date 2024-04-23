import SwiftUI
import Charts

struct RestingHRView: View {
    //let resting: [Double]
    @State var currentTab: String = "7 Days"
    
    var body: some View {
        VStack {
            Text("Resting Heart Rate")
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
            /*Chart {
                ForEach(resting.indices) { index in
                    let date = Calendar.current.date(byAdding: .day, value: index + 1, to: Date()) ?? Date()
                    LineMark(x: .value("Date", date, unit: .day), y: .value("BPM", resting[index]))
                }
            }*/
            .frame(maxWidth: .infinity, maxHeight: 300)
            
            //if resting.isEmpty {
                Text("No data available")
                    .foregroundColor(.secondary)
                    .padding(.vertical, 20)
            //}
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(20)
        .shadow(radius: 5)
        .padding()
    }
}

struct RestingChartViewWrapper: View {
    @StateObject var viewModel = RestingChartViewModel()
    
    var body: some View {
        Group {
            if let resting = viewModel.restingHeartRates {
                //RestingHRView(resting: resting)
            } else if let error = viewModel.error {
                Text("Error: \(error.localizedDescription)")
                    .foregroundColor(.red)
            } else {
                ProgressView()
            }
        }
        .onAppear {
            viewModel.fetchRestingForLast7Days()
        }
    }
}

class RestingChartViewModel: ObservableObject {
    @Published var restingHeartRates: [Double]?
    @Published var error: Error?
    
    func fetchRestingForLast7Days() {
        let healthKitManager = HealthKitManager()
        healthKitManager.fetchRestingHeartRateForLast7Days { rates, dates, error in
            DispatchQueue.main.async {
                if let rates = rates {
                    self.restingHeartRates = rates
                } else if let error = error {
                    self.error = error
                }
            }
        }
    }
}

struct RestingChartView_Previews: PreviewProvider {
    static var previews: some View {
        RestingChartViewWrapper()
    }
}

struct RestingHeartRateInfoView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
                
            
            Text("Resting heart rate (RHR) is the number of heartbeats per minute when the body is at rest. It's a measure of cardiovascular fitness and can be an indicator of overall health.")
                .font(.body)
                .foregroundColor(.secondary)
            
            Divider()
            
            Text("Factors Affecting RHR:")
                .font(.headline)
            
            Text("1. Fitness Level: Higher fitness levels are associated with lower RHR.")
                .font(.body)
                .foregroundColor(.secondary)
            
            Text("2. Age: RHR tends to increase with age.")
                .font(.body)
                .foregroundColor(.secondary)
            
            Text("3. Stress and Health Conditions: Stress and certain health conditions can elevate RHR.")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

struct RestingHeartRateInfoView_Previews: PreviewProvider {
    static var previews: some View {
        RestingHeartRateInfoView()
    }
}
