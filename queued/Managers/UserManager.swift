//
//  UserManager.swift
//  queued
//
//  Created by Ted Bennett on 28/03/2021.
//

import Combine
import SwiftKeychainWrapper

class UserManager: ObservableObject {
    static var shared = UserManager()
    private init() {
        if let id = KeychainWrapper.standard.string(forKey: "user-id") {
            getUser(id: id)
        } else {
            createUser()
        }
    }
    
    @Published var user: User?
    
    func createUser() {
        let id = FirebaseManager.shared.createUser()
        user = User(id: id)
        KeychainWrapper.standard.set(id, forKey: "user-id")
    }
    
    func getUser(id: String) {
        FirebaseManager.shared.getUser(id: id) { user in
            self.user = user
            if user == nil {
                print("Failed to obtain user")
            }
        }
    }
    
    func updateUser(_ user: User) -> Bool {
        let success = FirebaseManager.shared.updateUser(user)
        if success {
            self.user = user
        }
        return success
    }
}
