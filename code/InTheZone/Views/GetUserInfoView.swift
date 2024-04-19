//
//  GetUserInfoView.swift
//  InTheZone
//
//  Created by Alex Brankin on 19/04/2024.
//

import SwiftUI

struct WelcomeView: View {
    @StateObject private var userData = UserData()
    @State private var isNextViewActive = false
    @State private var selectedDate = Date()
    
    var body: some View {
        VStack {
            Image("bannertransparent")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 300)
                .padding(.top, -50)
            
                            
            Text("Welcome")
                .font(.title)
                .fontWeight(.bold)
                .padding()
            
            Text("Before we get started, lets get to know you!")

            VStack(alignment: .leading, spacing: 20) {
                TextField("What's your name?", text: $userData.name)
                    .padding()
                    .font(.headline)
                    .foregroundColor(.primary)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
                
                
                Text("When were you born?")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(.top, 5)
                    
                    DatePicker("Date of Birth", selection: $selectedDate, in: ...Date(), displayedComponents: .date)
                        .padding()
                        .datePickerStyle(.wheel)
                        .foregroundColor(.primary)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(8)
                        .labelsHidden()
            }
            .padding()

            Button(action: {
                // Validate user input before proceeding
                guard !userData.name.isEmpty else {
                    // Show an alert or error message for invalid input
                    return
                }
                isNextViewActive = true
            }) {
                Text("Continue")
                    .font(.headline)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.red)
                    .cornerRadius(10)
            }
            .padding()

            Spacer()
        }
        .padding()
        .ignoresSafeArea()
        .fullScreenCover(isPresented: $isNextViewActive) {
            ContentView()
                .environmentObject(userData) // Pass the userData object to the next view
        }
    }
}

struct NextView: View {
    @EnvironmentObject var userData: UserData

    var body: some View {
        VStack {
            Text("Welcome \(userData.name)!")
                .font(.title)
                .fontWeight(.bold)
                .padding()
            
            Text("Your age is \(userData.age).")
                .padding()
            
            // Other content of the NextView
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
