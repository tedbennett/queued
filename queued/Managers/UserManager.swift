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
    private init() { }
    
    // Not caching user for now
    
    func checkUser() {
        KeychainWrapper.standard.remove(forKey: "user-id")
        if let id = KeychainWrapper.standard.string(forKey: "user-id") {
            getUser(id: id) { _ in }
        } else {
            createUser()
        }
    }
    
    func createUser() {
        let id = FirebaseManager.shared.createUser()
        KeychainWrapper.standard.set(id, forKey: "user-id")
    }
    
    func getId() -> String? {
        return KeychainWrapper.standard.string(forKey: "user-id")
    }
    
    func getUser(id: String, completion: @escaping (User?) -> Void) {
        FirebaseManager.shared.getUser(id: id) {completion($0)}
    }
    
    func updateUser(_ user: User) -> Bool {
        return FirebaseManager.shared.updateUser(user)
    }
}
