//
//  UserData.swift
//  InTheZone
//
//  Created by Alex Brankin on 19/04/2024.
//

import Foundation

class UserData: ObservableObject {
    @Published var name: String {
        didSet {
            UserDefaults.standard.set(name, forKey: "userName")
        }
    }
    
    @Published var age: String {
        didSet {
            UserDefaults.standard.set(age, forKey: "userAge")
        }
    }
    
    init() {
        self.name = UserDefaults.standard.string(forKey: "userName") ?? ""
        self.age = UserDefaults.standard.string(forKey: "userAge") ?? ""
    }
}

