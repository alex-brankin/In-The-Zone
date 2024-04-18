//
//  ProfileViewModel.swift
//  InTheZone
//
//  Created by Alex Brankin on 18/04/2024.
//

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
}

