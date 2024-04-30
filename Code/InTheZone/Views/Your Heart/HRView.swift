//
//  InTheZone
//
//  Created by Alex Brankin on 02/03/2024.
//

import SwiftUI
import HealthKit

struct HRView: View {
    @StateObject private var healthKitManager = HealthKitManager()
    @State private var latestHeartRate: Double?
    @State private var lastCheckedTimestamp: Date?
    @State private var maxHeartRateForDay: Double?
    @State private var averageHeartRateForDay: Double?
    @State private var showMaxHeartRate = false
    @State private var showAverageHeartRate = false
    
    var currentDisplayedHeartRate: Double? {
        if showMaxHeartRate {
            return maxHeartRateForDay
        } else if showAverageHeartRate {
            return averageHeartRateForDay
        } else {
            return latestHeartRate
        }
    }
    
    var body: some View {
        VStack {
            ZStack {
                if let currentDisplayedHeartRate = currentDisplayedHeartRate, !showMaxHeartRate, !showAverageHeartRate {
                    AnimatedHeartView(currentBPM: currentDisplayedHeartRate)
                        .onTapGesture {
                            showMaxHeartRate.toggle()
                            showAverageHeartRate = false
                        }
                } else if showMaxHeartRate {
                    if let maxHeartRateForDay = maxHeartRateForDay {
                        AnimatedHeartView(currentBPM: maxHeartRateForDay)
                            .onTapGesture {
                                showMaxHeartRate = false
                                showAverageHeartRate = false
                            }
                    } else {
                        Text("N/A")
                    }
                } else if showAverageHeartRate {
                    if let averageHeartRateForDay = averageHeartRateForDay {
                        AnimatedHeartView(currentBPM: averageHeartRateForDay)
                            .onTapGesture {
                                showMaxHeartRate = false
                                showAverageHeartRate = false
                            }
                    } else {
                        Text("N/A")
                    }
                } else {
                    AnimatedHeartView(currentBPM: latestHeartRate ?? 0)
                        .onTapGesture {
                            showMaxHeartRate = false
                            showAverageHeartRate = false
                        }
                }
                
                VStack {
                    Text(showMaxHeartRate ? "Highest" : showAverageHeartRate ? "Average" : "")
                        .font(.headline)
                        .padding()
                        .offset(y: 110)
                        .colorInvert()
                    
                    Text("BPM")
                        .font(.largeTitle)
                        .padding()
                        .offset(y: 60)
                        .colorInvert()
                    
                    if let currentDisplayedHeartRate = currentDisplayedHeartRate {
                        Text("\(Int(currentDisplayedHeartRate))")
                            .font(.largeTitle)
                            .padding()
                            .offset(y: -80)
                            .colorInvert()
                    } else {
                        Text("N/A")
                            .font(.largeTitle)
                            .padding()
                            .offset(y: -80)
                            .colorInvert()
                    }
                }
            }
            
            if let lastCheckedTimestamp = lastCheckedTimestamp {
                Text("Last checked by Apple Watch: \(formattedTimestamp(lastCheckedTimestamp))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top)
            }
            else {
                Button(action: {
                    fetchHealthData()
                }) {
                    VStack{
                        Text("Please allow us access to your health data.")
                            .multilineTextAlignment(.center)
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        Text("Tap here to authorize.")
                            .multilineTextAlignment(.center)
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }
            }
            
        }
        .onAppear {
            fetchHealthData()
        }
    }
    
    private func fetchHealthData() {
        healthKitManager.requestAuthorization { success in
            if success {
                setupHeartRateObserver()
                fetchHeartRateData()
                fetchHeartRateMax()
                fetchHeartRateAverage()
            } else {
               
            }
        }
    }
    
    func fetchHeartRateData() {
        print("Fetching heart rate data...")
        
        healthKitManager.fetchMostRecentHeartRate { heartRate, timestamp, error in
            if let error = error {
                print("Error fetching heart rate: \(error.localizedDescription)")
                return
            }
            
            if let heartRate = heartRate, let timestamp = timestamp {
                print("Latest heart rate: \(heartRate) BPM (Timestamp: \(timestamp))")
                DispatchQueue.main.async {
                    self.latestHeartRate = heartRate
                    self.lastCheckedTimestamp = timestamp
                }
            }
        }
    }
    
    func fetchHeartRateMax() {
        healthKitManager.fetchMaximumHeartRateForDay { maxHeartRate, error in
            if let error = error {
                print("Error fetching maximum heart rate: \(error.localizedDescription)")
                return
            }
            
            if let maxHeartRate = maxHeartRate {
                print("Maximum heart rate for the day: \(maxHeartRate)")
                DispatchQueue.main.async {
                    self.maxHeartRateForDay = maxHeartRate
                }
            }
        }
    }

    func fetchHeartRateAverage() {
        healthKitManager.fetchAverageHeartRateForDay { averageHeartRate, error in
            if let error = error {
                print("Error fetching average heart rate: \(error.localizedDescription)")
                return
            }
            
            if let averageHeartRate = averageHeartRate {
                print("Average heart rate for the day: \(averageHeartRate)")
                DispatchQueue.main.async {
                    self.averageHeartRateForDay = averageHeartRate
                }
            }
        }
    }


    private func formattedTimestamp(_ timestamp: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy 'at' HH:mm:ss"
        return formatter.string(from: timestamp)
    }
    
    func setupHeartRateObserver() {
        healthKitManager.startHeartRateObserver { heartRate, error in
            if let error = error {
                print("Error observing heart rate: \(error.localizedDescription)")
                return
            }
            
            if let heartRate = heartRate {
                DispatchQueue.main.async {
                    self.latestHeartRate = heartRate
                }
            }
        }
    }
}

struct AnimatedHeartView: View {
    var currentBPM: Double
    
    @State private var isHeartBeating: Bool = false 
    
    // Define minimum and maximum animation durations
    private let minDuration: Double = 0.3
    private let maxDuration: Double = 2.0
    
    var body: some View {
        Image(systemName: "heart.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 200, height: 200)
            .foregroundColor(.red)
            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
            .scaleEffect(isHeartBeating ? 1.2 : 1.0)
            .opacity(isHeartBeating ? 1.0 : 0.8)
            .onAppear {
                startAnimationIfNeeded()
            }
    }
    
    private func startAnimationIfNeeded() {
        // Clamp heart rate values to ensure they fall within a reasonable range
        let clampedBPM = min(max(currentBPM, 30), 210) // Apple Watch Limitations
        
        // Print current BPM
        print("Animation BPM: \(clampedBPM)")
        
        if clampedBPM > 30 {
            // Calculate animation duration based on the heart rate
            let duration = 60 / clampedBPM
            print("Duration: \(duration)")
            
            // Scale animation speed based on heart rate
            withAnimation(Animation.linear(duration: duration).repeatForever(autoreverses: true)) {
                self.isHeartBeating = true
            }
        } else {
            // Stop the animation if the heart rate is zero
            self.isHeartBeating = false
        }
    }
}

struct HRView_Previews: PreviewProvider {
    static var previews: some View {
        HRView()
    }
}
