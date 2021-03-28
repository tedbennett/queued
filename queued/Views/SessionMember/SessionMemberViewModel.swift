//
//  SessionMemberViewModel.swift
//  queued
//
//  Created by Ted Bennett on 28/03/2021.
//

import Foundation
import Combine

class SessionMemberViewModel: ObservableObject {
    @Published var session: Session?
    @Published var joined = false
    
    func joinSession(with key: String) {
        FirebaseManager.shared.joinSession(key: key) { [weak self] session in
            if let session = session {
                self?.session = session
                self?.joined = true
                self?.startListening()
            }
        }
    }
    
    func startListening() {
        guard let id = session?.id else {
            return
        }
        FirebaseManager.shared.listenToSession(id: id) { [weak self] session in
            guard let session = session else {
                print("Failed to download listented session")
                return
            }
            self?.session = session
        }
    }
}
