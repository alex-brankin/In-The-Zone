//
//  InTheZone
//
//  Created by Alex Brankin on 02/03/2024.
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
    @State private var errorMessage = ""

    
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
                
                DatePicker("Date of Birth", selection: $userData.dateOfBirth, in: ...Date(), displayedComponents: .date)
                    .padding()
                    .datePickerStyle(.wheel)
                    .foregroundColor(.primary)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
                    .labelsHidden()
            }
            .padding()
            
            if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .padding(.top)
                        }

                        Button(action: {
                            // Validate user input before proceeding
                            if !validateUserData() {
                                return
                            }
                            isNextViewActive = true
                        }) {
                            Text("Continue")
                                .frame(width: 300)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .padding(.horizontal)
                                .shadow(radius: 5)
                        }
                        .padding()

                        Spacer()
                    }
                    .padding()
                    .ignoresSafeArea()
                    .fullScreenCover(isPresented: $isNextViewActive) {
                        ContentView()
                            .environmentObject(userData)
                    }
                }

                // Function to validate user input
                func validateUserData() -> Bool {
                    errorMessage = ""

                    // Check if name is not empty
                    guard !userData.name.isEmpty else {
                        errorMessage = "It seems you forgot to tell us your name!"
                        return false
                    }

                    // Check if age is valid
                    guard userData.calculatedAge > 0 else {
                        errorMessage = "It seems you forgot to select your date of birth!"
                        return false
                    }
                    // Check if user is 4 years or older
                    guard userData.calculatedAge > 3 else {
                        errorMessage = "Our app is designed for users aged 4 and above."
                        return false
                    }


                    return true
                }
            }

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
