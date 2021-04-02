//
//  SessionManager.swift
//  queued
//
//  Created by Ted Bennett on 02/04/2021.
//

import Combine
import Dispatch

class SessionManager: ObservableObject {
    static let shared = SessionManager()
    private init() { }
    
    @Published var isSessionMember = false
    @Published var isSessionHost = false
    
    @Published var session: Session? {
        didSet {
            if session == nil {
                isSessionMember = false
                isSessionHost = false
            } else {
                if session?.host == UserManager.shared.getId() {
                    isSessionHost = true
                } else {
                    isSessionMember = true
                }
            }
        }
    }
    @Published var users: [User] = []
    
    func getSession(id: String) {
        NetworkManager.shared.getSession(id: id) { session in
            DispatchQueue.main.async {
                self.session = session
            }
        }
    }
    
    func getUsers(ids: [String]) {
        let group = DispatchGroup()
        var users: [User] = []
        ids.forEach {
            group.enter()
            NetworkManager.shared.getUser(id: $0) { user in
                if let user = user {
                    users.append(user)
                }
                group.leave()
            }
        }
        group.notify(queue: .main) {
            self.users = users
        }
    }
    
    func createSession(name: String) {
        NetworkManager.shared.createSession(name: name) { session in
            DispatchQueue.main.async {
                self.session = session
            }
            NetworkManager.shared.listenToSession(id: session!.id, connectionChanged: { _ in}) { session in
                DispatchQueue.main.async {
                    self.session = session
                }
            }
        }
    }
    
    func joinSession(id: String) {
        NetworkManager.shared.joinSession(id: id){ session in
            DispatchQueue.main.async {
                self.session = session
            }
            guard let session = session else { return }
            NetworkManager.shared.listenToSession(id: session.id, connectionChanged: { _ in}) { newSession in
                DispatchQueue.main.async {
                    self.session = newSession
                }
            }
        }
    }
    
    func leaveSession() {
        guard let id = session?.id else { return }
        NetworkManager.shared.leaveSession(id: id) { success in
            if success {
                DispatchQueue.main.async {
                    self.session = nil
                }
            }
        }
    }
    
    func deleteSession() {
        guard let id = session?.id else { return }
        NetworkManager.shared.deleteSession(id: id) { success in
            if success {
                DispatchQueue.main.async {
                    self.session = nil
                }
            }
        }
    }
}
