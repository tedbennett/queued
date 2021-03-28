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
        if KeychainWrapper.standard.string(forKey: "user-id") == nil {
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
    
    func getUser(completion: @escaping (User?) -> Void) {
        guard let id = getId() else { return }
        FirebaseManager.shared.getUser(id: id) {completion($0)}
    }
    
    func updateUser(name: String, imageUrl: String?) -> Bool {
        guard let id = getId() else { return false }
        let user = User(id: id, name: name, imageUrl: imageUrl)
        return FirebaseManager.shared.updateUser(user)
    }
}
