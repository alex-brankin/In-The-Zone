//
//  InTheZone
//
//  Created by Alex Brankin on 02/03/2024.
//
// The ProfileViewModel class in SwiftUI manages the user's profile image using the PhotosUI framework. It utilizes
// @Published properties to update the UI asynchronously when a new image is selected or loaded. The model handles
// the loading of image data from the PhotosPicker and saves this data to the device's document directory for
// persistent storage. Additionally, it provides functionality to load the saved image from the filesystem during
// initialization or when required, ensuring the image remains accessible across app sessions. The asynchronous
// tasks are handled safely using Swift's concurrency features, specifically async/await patterns.

import SwiftUI
import PhotosUI

class ProfileViewModel: ObservableObject {
    @Published var selectedItem: PhotosPickerItem? {
        didSet { Task { try await loadImage() }}
    }
    @Published var profileImage: Image?
    
    private let profileImageFileName = "profileImage.png"
    
    func loadImage() async throws {
        guard let item = selectedItem else { return }
        guard let imageData = try await item.loadTransferable(type: Data.self) else { return }
        guard let uiImage = UIImage(data: imageData) else { return }
        
        // Save the image data to a file
        saveImageToDocumentDirectory(imageData)
        
        // Update the profileImage property on the main thread
        DispatchQueue.main.async {
            self.profileImage = Image(uiImage: uiImage)
        }
    }
    
    func saveImageToDocumentDirectory(_ imageData: Data) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(profileImageFileName)
        
        do {
            try imageData.write(to: fileURL)
        } catch {
            print("Error saving image data: \(error)")
        }
    }
    
    func loadProfileImage() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(profileImageFileName)
        
        do {
            let imageData = try Data(contentsOf: fileURL)
            let uiImage = UIImage(data: imageData)
            self.profileImage = Image(uiImage: uiImage!)
        } catch {
            print("Error loading profile image: \(error)")
        }
    }
    
    func removeProfilePicture() {
                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let fileURL = documentsDirectory.appendingPathComponent(profileImageFileName)
                
                do {
                    try FileManager.default.removeItem(at: fileURL)
                    profileImage = nil // Reset profileImage property
                } catch {
                    print("Error removing profile picture: \(error)")
                }
            }
}

