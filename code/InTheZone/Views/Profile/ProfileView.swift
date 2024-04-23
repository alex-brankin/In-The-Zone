//
//  ProfileView.swift
//  InTheZone
//
//  Created by Alex Brankin on 03/04/2024.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    @StateObject var viewModel = ProfileViewModel()
    @EnvironmentObject var userData: UserData
    @AppStorage("fullName") private var fullName: String = ""
    @AppStorage("age") private var age: Int = 0
    @State private var showingImagePicker = false
    @State private var isDatePickerShown = false
    
    var body: some View {
        VStack {
            PhotosPicker(selection: $viewModel.selectedItem){
                if let profileImage = viewModel.profileImage{
                    profileImage
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                        .shadow(radius: 10)
                } else {
                    Image(systemName: "person.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .foregroundStyle(.black)
                    
                }
            }
            .onAppear {
                viewModel.loadProfileImage()
            }
            
            Text(userData.name) // Display user's name
                .font(.title)
            
            Form {
                // Personal Information Section
                Section(header: Text("Personal Information")) {
                    TextField("Full Name", text: $userData.name)
                    Button(action: {
                        isDatePickerShown = true
                    }) {
                        Text("Age: \(userData.calculatedAge)")
                            .foregroundStyle(.red)
                    }
                }
                .sheet(isPresented: $isDatePickerShown) {
                    DatePickerSheet(selectedDate: $userData.dateOfBirth, isDatePickerShown: $isDatePickerShown)
                        .presentationDetents([.medium, .large])
                    
                        
                }
                
                // Achievements Section
                Section(header: Text("Achievements")) {
                    // Grid of images and text placeholders
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3)) {
                        VStack {
                            Image("TrophyUKITZ")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                            Text("UK Distance")
                                .font(.caption)
                        }
                        VStack {
                            Image("StepTrophy")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                            Text("Annual Step Goal")
                                .font(.caption)
                        }
                        VStack {
                            Image("HRTrophy")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                            Text("Zone 2 Champion")
                                .font(.caption)
                        }
                        
                        ForEach(1..<7) { index in
                            VStack {
                                Image("placeholdertrophy")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                Text("Locked")
                                    .font(.caption)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

struct DatePickerSheet: View {
    @EnvironmentObject var userData: UserData
    @Binding var selectedDate: Date
    @Binding var isDatePickerShown: Bool
    @State private var errorMessage = ""

    var body: some View {
        VStack {
            Text("Select your Date of Birth")
                .font(.headline)
                .padding()
            
            DatePicker("", selection: $selectedDate, in: ...Date(), displayedComponents: .date)
                .datePickerStyle(WheelDatePickerStyle())
                .padding()
                .frame(width: 345)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(16)
                .shadow(radius: 5)
                .padding(.bottom, 20)
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
            
            Button("Confirm") {
                // Validate user input before proceeding
                if validateUserData() {
                    // Additional checks specific to the button action
                    if userData.calculatedAge < 4 {
                        errorMessage = "Our app is designed for users aged 4 and above."
                        return
                    }

                    isDatePickerShown = false // Close the sheet when the user confirms
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(8)
            .padding(.horizontal)
            .shadow(radius: 5)
            
            Spacer()
        }
        .padding()
        .background(Color.clear)
    }

    func validateUserData() -> Bool {
        errorMessage = ""

        // Check if age is valid
        guard userData.calculatedAge > 0 else {
            errorMessage = "It seems you forgot to select your date of birth!"
            return false
        }

        // Additional check for age greater than 3
        guard userData.calculatedAge > 3 else {
            errorMessage = "Our app is designed for users aged 4 and above."
            return false
        }

        return true
    }
}




struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(UserData())
    }
}
