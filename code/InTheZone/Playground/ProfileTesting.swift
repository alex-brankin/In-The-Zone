//
//  ProfileTesting.swift
//  InTheZone
//
//  Created by Alex Brankin on 17/04/2024.
//

import SwiftUI

struct TestProfile: View {
    @State private var uiImage: UIImage?
    @State private var showingImagePicker = false
    
    var body: some View {
        VStack {
            // Display either the selected image or a placeholder image
            if let image = uiImage {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 150, height: 150) // Fixed size for the image
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    .shadow(radius: 10)
            } else {
                Image(systemName: "person.circle.fill") // Placeholder image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                    .foregroundColor(.gray)
            }
            
            Button(action: {
                self.showingImagePicker = true
            }) {
                Text("Select Profile Picture")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
        }
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
            ProfilePicturePicker(uiImage: self.$uiImage)
        }
        .onAppear(perform: loadImage)
    }
    
    // Load image from UserDefaults
    func loadImage() {
        guard let path = UserDefaults.standard.string(forKey: "profilePicturePath"),
              let uiImage = UIImage(contentsOfFile: path) else { return }
        self.uiImage = uiImage
    }
}



struct ProfilePicturePicker: UIViewControllerRepresentable {
    @Binding var uiImage: UIImage?
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ProfilePicturePicker

        init(_ parent: ProfilePicturePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.uiImage = uiImage
                saveImage(uiImage)
            }

            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func saveImage(_ uiImage: UIImage) {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileName = "profilePicture.png"
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            
            if let data = uiImage.pngData() {
                do {
                    try data.write(to: fileURL)
                    UserDefaults.standard.set(fileURL.path, forKey: "profilePicturePath")
                } catch {
                    print("Error saving image: \(error)")
                }
            }
        }
    }
}


struct TestProfile_Previews: PreviewProvider {
    static var previews: some View {
        TestProfile()
    }
}
