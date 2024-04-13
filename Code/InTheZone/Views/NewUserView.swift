//
//  NewUserView.swift
//  InTheZone
//
//  Created by Alex Brankin on 13/04/2024.
//

import SwiftUI
import HealthKit

struct NewUserView: View {
    @State private var isAuthorized = false
    @State private var navigationActive: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                Rectangle()
                    .frame(height: 500)
                    .foregroundColor(.red) // Change color as needed
                    .ignoresSafeArea()
                    .padding(.bottom, -30)
                    .overlay(
                        Text("Welcome Image")
                            .foregroundColor(.white)
                            .font(.title)
                    )
                
                VStack(spacing: 12) {
                    Text("Find Your Zone")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Welcome to ")
                        .foregroundColor(.secondary)
                    +
                    Text("In The Zone")
                        .bold()
                        .foregroundColor(.primary)
                    +
                    Text(", your ultimate companion for zone training excellence. Whether you're an athlete striving for peak performance or a fitness enthusiast looking to elevate your workouts, our app is here to guide you every step of the way. Get ready to dive into the zone and unlock your full potential with targeted training and real-time feedback. Let's embark on this journey together and reach new heights of fitness success!")
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button("Get Started") {
                        HealthKitManager().requestAuthorization { success in
                            if success {
                                print("HealthKit authorization granted.")
                                // Update the authorization status and trigger navigation
                                self.isAuthorized = true
                                self.navigationActive = true
                            } else {
                                print("HealthKit authorization failed.")
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    .opacity(isAuthorized ? 0 : 1)
                    
                    Spacer()
                }
                .padding(.horizontal)
                .multilineTextAlignment(.center)
            }
            .background(
                EmptyView()
                    .navigationDestination(isPresented: $navigationActive) {
                        ContentView()
                            .navigationBarBackButtonHidden(true)
                    }
                    .hidden()
            )
        }
    }
}

struct NewUserView_Previews: PreviewProvider {
    static var previews: some View {
        NewUserView()
    }
}

