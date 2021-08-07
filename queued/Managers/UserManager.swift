//
//  UserManager.swift
//  queued
//
//  Created by Ted Bennett on 28/03/2021.
//
import SwiftUI
import Combine
import Dispatch
import SwiftKeychainWrapper

class UserManager: ObservableObject {
    static var shared = UserManager()
    private init() {
        if let savedUser = UserDefaults.standard.object(forKey: "user") as? Data,
           let loadedUser = try? JSONDecoder().decode(User.self, from: savedUser) {
            self.user = loadedUser
        } else {
            let id = UUID().uuidString
            self.user = User(id: id)
            self.user.name = ""
            FirebaseManager.shared.createUser(id: id) { _ in }
            self.saveUser()
        }
    }
    
    @Published var user: User
    
    func checkSession(completion: @escaping (Bool) -> Void) {
        if let session = user.session {
            SessionManager.shared.getSession(id: session, startListening: true) {
                completion($0)
            }
        } else {
            completion(false)
        }
    }
    
    func saveUser() {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: "user")
        }
    }
    
    func updateUser(name: String, imageUrl: String?, completion: @escaping (Bool) -> Void) {
        FirebaseManager.shared.updateUser(name: name) { success in
            if success {
                DispatchQueue.main.async {
                    self.user.name = name
                    self.user.imageUrl = imageUrl
                    self.saveUser()
                }
            }
            completion(success)
        }
    }
    
    func authoriseWithSpotify(code: String) {
        FirebaseManager.shared.authoriseWithSpotify(code: code) { success in
            DispatchQueue.main.async {
                self.user.host = success
                self.saveUser()
            }
        }
    }
    
    func logoutFromSpotify() {
        FirebaseManager.shared.logoutFromSpotify() { success in
            DispatchQueue.main.async {
                self.user.host = !success
                self.saveUser()
            }
        }
    }
}
