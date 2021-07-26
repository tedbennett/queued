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
    
    @Published var sessionEnded = false
    @Published var failedToFindSession = false
    
    @Published var addedSongToSession = false
    @Published var failedToAddSong = false
    
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
    
    func getSession(id: String, startListening: Bool = false) {
        NetworkManager.shared.getSession(id: id) { session in
            if let session = session {
                DispatchQueue.main.async {
                    self.session = session
                }
                self.getUsers(ids: session.members)
                self.listenToSession()
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
            if let ids = session?.members {
                self.getUsers(ids: ids)
            }
            self.listenToSession()
        }
    }
    
    func updateSession(name: String) {
        guard let id = session?.id else { return }
        NetworkManager.shared.updateSession(id: id, name: name) { _ in }
    }
    
    func addSongToSession(song: Song) {
        guard let id = session?.id else { return }
        NetworkManager.shared.addSongToQueue(song, sessionId: id) { success in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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
        NetworkManager.shared.joinSession(id: id) { session in
            DispatchQueue.main.async {
                self.session = session
                if session != nil {
                    self.listenToSession()
                }
            }
        }
    }
    
    func findAndJoinSession(key: String) {
        NetworkManager.shared.getSession(key: key) { session in
            if let id = session?.id {
                self.joinSession(id: id)
            } else {
                DispatchQueue.main.async {
                    self.failedToFindSession = true
                }
            }
        }
    }
    
    func checkCurrentlyPlaying() {
        guard let id = session?.id else { return }
        NetworkManager.shared.checkCurrentlyPlaying(id: id)
    }
    
    func leaveSession() {
        guard let id = session?.id else { return }
        NetworkManager.shared.leaveSession(id: id) { success in
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
        NetworkManager.shared.deleteSession(id: id) { success in
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
        NetworkManager.shared.listenToSession(id: session.id, connectionChanged: { _ in }) { newSession in
            guard let newSession = newSession else {
                DispatchQueue.main.async {
                    self.session = nil
                    self.sessionEnded = true
                }
                NetworkManager.shared.stopListeningToSession()
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
