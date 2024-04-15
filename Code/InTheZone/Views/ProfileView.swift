//
//  ProfileView.swift
//  InTheZone
//
//  Created by Alex Brankin on 03/04/2024.
//

import SwiftUI
import UIKit

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: Image?

    @Environment(\.presentationMode) var presentationMode

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = Image(uiImage: uiImage)
            }

            parent.presentationMode.wrappedValue.dismiss()
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        // Not needed
    }
}


struct ProfileView: View {
    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var age: Int = 0
    @State private var weight: Double = 0.0
    @State private var height: Double = 0.0
    @State private var profileImage: Image? = nil
    @State private var showingImagePicker = false

    var body: some View {
            VStack(alignment: .center) { // Align content in the center
                if let image = profileImage {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                }
                Button(action: {
                    showingImagePicker = true
                }) {
                    Text("Select Profile Picture")
                }
                .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                    ImagePicker(image: $profileImage)
                }
                
                Form {
                    Section(header: Text("Personal Information")) {
                        TextField("Full Name", text: $fullName)
                        TextField("Email", text: $email)
                        Stepper(value: $age, in: 0...150, label: {
                            Text("Age: \(age)")
                        })
                    }
                    
                    Section(header: Text("Physical Information")) {
                        Stepper(value: $weight, in: 0...300, step: 1, label: {
                            Text("Weight: \(weight, specifier: "%.1f") kg")
                        })
                        Stepper(value: $height, in: 0...300, step: 1, label: {
                            Text("Height: \(height, specifier: "%.1f") cm")
                        })
                    }
                    
                    Section(header: Text("Settings")) {
                        NavigationLink(destination: SettingsView()) {
                            Text("Settings")
                        }
                    }
                    
                    Section {
                        Button(action: {
                            // Save profile changes
                        }) {
                            Text("Save Changes")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
    
    
    func loadImage() {
        guard let selectedImage = profileImage else { return }
        profileImage = selectedImage
    }
}


struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}

