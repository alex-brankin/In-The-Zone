//
//  GetUserInfoView.swift
//  InTheZone
//
//  Created by Alex Brankin on 19/04/2024.
//

import SwiftUI

struct TextFieldLimitModifer: ViewModifier {
    @Binding var value: String
    var length: Int

    func body(content: Content) -> some View {
        content
            .onReceive(value.publisher.collect()) {
                value = String($0.prefix(length))
            }
    }
}

extension View {
    func limitInputLength(value: Binding<String>, length: Int) -> some View {
        self.modifier(TextFieldLimitModifer(value: value, length: length))
    }
}

struct WelcomeView: View {
    @StateObject private var userData = UserData()
    @State private var isNextViewActive = false
    @State private var selectedDate = Date()
    let maxNameLength = 25
    
    @State private var errorMessage: String? // Define state variable for error message
    
    var body: some View {
        VStack {
            Image("bannertransparent")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 300)
                .padding(.top, -50)
            
            Text("Welcome \(userData.name)")
                .font(.title)
                .fontWeight(.bold)
                .padding()
            
            Text("Before we get started, let's get to know you!")
            
            VStack(alignment: .leading, spacing: 20) {
                TextField("What's your name?", text: $userData.name)
                    .padding()
                    .limitInputLength(value: $userData.name, length: maxNameLength)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
                
                Text("When were you born?")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding(.top, 5)
                
                DatePicker("Date of Birth", selection: $userData.dateOfBirth, in: ...Date().addingTimeInterval(-4*365*24*60*60), displayedComponents: .date)
                    .padding()
                    .datePickerStyle(.wheel)
                    .foregroundColor(.primary)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
                    .labelsHidden()
            }
            .padding()
            
            if let errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.top)
            }
            
            Button(action: {
                // Validate user input before proceeding
                guard validateUserData() else {
                    errorMessage = "It seems you forgot to tell us your name!"
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
    
    // Function to validate user input
    func validateUserData() -> Bool {
        // Check if name is not empty
        guard !userData.name.isEmpty else {
            return false
        }
        
        // Additional validation logic can be added here
        
        return true
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
