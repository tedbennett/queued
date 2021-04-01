//
//  SessionMemberViewModel.swift
//  queued
//
//  Created by Ted Bennett on 28/03/2021.
//

import Foundation
import Combine

class SessionMemberViewModel: ObservableObject {
    private var listenerId = ""
    @Published var session: Session?
    @Published var joined = false
    
    func joinSession(with key: String) {
        NetworkManager.shared.getSession(key: key) { [weak self] session in
            guard let session = session else {
                // TODO: Failed to find session
                return
            }
            NetworkManager.shared.joinSession(id: session.id) { [weak self] joinedSession in
                DispatchQueue.main.async {
                    if let joinedSession = joinedSession {
                        self?.session = joinedSession
                        self?.joined = true
                        NetworkManager.shared.listenToSession(id: joinedSession.id, connectionChanged: { connected in
                            print(connected ? "Listening" : "Stopped listening")
                        }, sessionChanged: { session in
                            self?.session = session
                        })
                    }
                }
            }
        }
        
    }
    
    // TODO: Reimplement listeners
    
    static var example: SessionMemberViewModel {
        let viewModel = SessionMemberViewModel()
        
        viewModel.session = Session.example
        return viewModel
    }
}
