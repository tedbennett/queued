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
        if KeychainWrapper.standard.string(forKey: "user-id") == nil {
            createUser()
        }
    }
    
    func createUser() {
        NetworkManager.shared.createUser() { id in
            guard let id = id else { return }
            KeychainWrapper.standard.set(id, forKey: "user-id")
        }
    }
    
    func getId() -> String? {
        return KeychainWrapper.standard.string(forKey: "user-id")
    }
    
    func getUser(completion: @escaping (User?) -> Void) {
        guard let id = getId() else { return }
        NetworkManager.shared.getUser(id: id) {completion($0)}
    }
    
    func updateUser(name: String, imageUrl: String?, completion: @escaping (Bool) -> Void) {
        NetworkManager.shared.updateUser(name: name, imageUrl: imageUrl) {completion($0)}
    }
}
