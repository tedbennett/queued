//
//  UserManager.swift
//  queued
//
//  Created by Ted Bennett on 28/03/2021.
//

import Combine
import Dispatch
import SwiftKeychainWrapper

class UserManager: ObservableObject {
    static var shared = UserManager()
    private init() { }
    
    @Published var user: User?
    
    func checkUser() {
        if KeychainWrapper.standard.string(forKey: "user-id") == nil {
            createUser()
        } else {
            getUser { user in
                if let session = user?.session {
                    SessionManager.shared.getSession(id: session, startListening: true)
                }
            }
        }
    }
    
    func createUser() {
        NetworkManager.shared.createUser() { id in
            guard let id = id else { return }
            KeychainWrapper.standard.set(id, forKey: "user-id")
            self.getUser() { _ in }
        }
    }
    
    func getId() -> String? {
        return KeychainWrapper.standard.string(forKey: "user-id")
    }
    
    func getUser(completion: @escaping (User?) -> Void) {
        guard let id = getId() else { return }
        NetworkManager.shared.getUser(id: id) { user in
            DispatchQueue.main.async {
                self.user = user
            }
            completion(user)
        }
    }
    
    func updateUser(name: String, imageUrl: String?, completion: @escaping (Bool) -> Void) {
        NetworkManager.shared.updateUser(name: name, imageUrl: imageUrl) { [weak self] in
            if $0 {
                DispatchQueue.main.async {
                    self?.user?.name = name
                    self?.user?.imageUrl = imageUrl
                }
            }
            completion($0)
        }
    }
    
    func authoriseWithSpotify(code: String) {
        NetworkManager.shared.authoriseWithSpotify(code: code) { success in
            DispatchQueue.main.async {
                self.user?.host = success
            }
        }
    }
    
    func logoutFromSpotify() {
        NetworkManager.shared.logoutFromSpotify() { success in
            DispatchQueue.main.async {
                self.user?.host = !success
            }
        }
    }
}
