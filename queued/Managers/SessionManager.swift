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
    
    @Published var inSession = false
    
    @Published var canQueue = true
    
    @Published var sessionEnded = false
    @Published var failedToFindSession = false
    
    @Published var addedSongToSession = false
    @Published var failedToAddSong = false
    
    @Published var session: Session? {
        didSet {
            inSession = session != nil
        }
    }
    @Published var users: [User] = []
    
    func getSession(id: String, startListening: Bool = false, completion: @escaping (Bool) -> Void) {
        FirebaseManager.shared.getSession(id: id) { session in
            if let session = session {
                DispatchQueue.main.async {
                    self.session = session
                    if startListening {
                        self.listenToSession()
                    }
                }
                self.getUsers(ids: session.members)
                
            }
            completion(session != nil)
        }
    }
    
    func getUsers(ids: [String]) {
        let group = DispatchGroup()
        var users: [User] = []
        ids.forEach {
            group.enter()
            FirebaseManager.shared.getUser(id: $0) { user in
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
        FirebaseManager.shared.createSession(name: name) { session in
            DispatchQueue.main.async {
                self.session = session
                self.listenToSession()
                if let id = session?.id {
                    UserManager.shared.addUserToSession(id: id)
                }
            }
            if let ids = session?.members {
                self.getUsers(ids: ids)
            }
        }
    }
    
    func updateSession(name: String) {
        guard let id = session?.id else { return }
        FirebaseManager.shared.updateSessionName(id: id, name: name) { _ in }
    }
    
    func updateSession(delay: Int) {
        guard let id = session?.id else { return }
        FirebaseManager.shared.updateSessionDelay(id: id, delay: delay) { _ in }
    }
    
    func addSongToSession(song: Song) {
        guard let id = session?.id else { return }
        FirebaseManager.shared.addSongToQueue(song, sessionId: id) { success in
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                if success {
                    self.addedSongToSession = true
                    self.checkCurrentlyPlaying()
                } else {
                    self.failedToAddSong = true
                }
            }
        }
    }
    
    func joinSession(id: String) {
        FirebaseManager.shared.joinSession(id: id) { session in
            DispatchQueue.main.async {
                self.session = session
                if session != nil {
                    self.listenToSession()
                }
                UserManager.shared.addUserToSession(id: id)
                self.checkCurrentlyPlaying()
            }
        }
    }
    
//    func findAndJoinSession(key: String) {
//        FirebaseManager.shared.getSession(key: key) { session in
//            if let id = session?.id {
//                self.joinSession(id: id)
//            } else {
//                DispatchQueue.main.async {
//                    self.failedToFindSession = true
//                }
//            }
//        }
//    }
    
    func checkCurrentlyPlaying() {
        guard let id = session?.id else { return }
        FirebaseManager.shared.checkCurrentlyPlaying(id: id)
    }
    
    func leaveSession() {
        guard let id = session?.id else { return }
        UserManager.shared.removeUserFromSession()
        FirebaseManager.shared.leaveSession(id: id) { success in
            if success {
                DispatchQueue.main.async {
                    self.session = nil
                    self.users = []
                }
            }
        }
    }
    
    func deleteSession() {
        guard let id = session?.id else { return }
        UserManager.shared.removeUserFromSession()
        FirebaseManager.shared.deleteSession(id: id) { success in
            if success {
                DispatchQueue.main.async {
                    self.session = nil
                    self.users = []
                }
            }
        }
    }
    
    func listenToSession() {
        guard let session = session else { return }
        checkCurrentlyPlaying()
        FirebaseManager.shared.listenToSession(id: session.id) { newSession in
            guard let newSession = newSession else {
                DispatchQueue.main.async {
                    self.session = nil
                    self.sessionEnded = true
                }
                FirebaseManager.shared.stopListeningToSession()
                return
            }
            if newSession.members != self.session?.members {
                self.getUsers(ids: newSession.members)
            }
            
            DispatchQueue.main.async {
                self.session = newSession
            }
        }
    }
    
    
    
    static var exampleHost: SessionManager {
        let manager = SessionManager()
        manager.session = Session.example
        manager.users = [User(id: "abc", name: "Nick"), User(id: "abce", name: "Mike"), User(id: "abcd", name: "Ted"),User(id: "asd", name: "James"),User(id: "asdf", name: "John"),User(id: "safg", name: "Dom")]
        return manager
    }
}
