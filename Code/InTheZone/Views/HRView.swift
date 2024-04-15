//
//  HRView.swift
//  InTheZone
//
//  Created by Alex Brankin on 03/04/2024.
//

import SwiftUI
import HealthKit

struct HRView: View {
    @StateObject private var healthKitManager = HealthKitManager()
    @State private var latestHeartRate: Double?
    @State private var lastCheckedTimestamp: Date?

    var body: some View {
        VStack {
            ZStack {
                if let latestHeartRate = latestHeartRate {
                    AnimatedHeartView(currentBPM: latestHeartRate)
                } else {
                    AnimatedHeartView(currentBPM: 0)
                }
                VStack {
                    
                    Text("Current")
                        .font(.headline)
                        .padding()
                        .offset(y: 110)
                    
                    Text("BPM")
                        .font(.largeTitle)
                        .padding()
                        .offset(y: 60)
                    
                    if let latestHeartRate = latestHeartRate {
                        Text("\(Int(latestHeartRate))")
                            .font(.largeTitle)
                            .padding()
                            .offset(y: -80)
                    } else {
                        Text("N/A")
                            .font(.largeTitle)
                            .padding()
                            .offset(y: -80)
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
                Text("Please allow us access to your health data in order to fetch your heart rate data.")
                    .multilineTextAlignment(.center)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top)
            }
            
        }
        .onAppear {
            fetchHeartRateData()
            setupHeartRateObserver()
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
    
    @State private var isHeartBeating: Bool = false // Initialize with false
    
    // Define minimum and maximum animation durations
    private let minDuration: Double = 0.3
    private let maxDuration: Double = 2.0
    
    var body: some View {
        Image(systemName: "heart.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 200, height: 200)
            .foregroundColor(.red)
            .scaleEffect(isHeartBeating ? 1.2 : 1.0)
            .opacity(isHeartBeating ? 1.0 : 0.8)
            .onAppear {
                startAnimationIfNeeded()
            }
            .onChange(of: currentBPM) { newBPM, _ in
                startAnimationIfNeeded()
            }
    }
    
    private func startAnimationIfNeeded() {
        // Clamp heart rate values to ensure they fall within a reasonable range
        let clampedBPM = min(max(currentBPM, 20), 200)
        
        // Print current BPM
        print("Animation BPM: \(clampedBPM)")
        
        if clampedBPM > 20 {
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
