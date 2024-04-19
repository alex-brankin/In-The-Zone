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
                    Stepper(value: $age, in: 0...150, label: {
                        Text("Age: \(age)")
                    })
                }
                
                // Achievements Section
                // Achievements Section
                Section(header: Text("Achievements")) {
                    // Grid of images and text placeholders
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3)) {
                        VStack {
                            Image("TrophyUKITZ")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                            Text("UK Trophy")
                                .font(.caption)
                        }
                        ForEach(1..<9) { index in
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

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(UserData())
    }
}
