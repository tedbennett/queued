//
//  SessionHostViewModel.swift
//  queued
//
//  Created by Ted Bennett on 28/03/2021.
//

import Foundation
import Combine

class SessionHostViewModel: ObservableObject {
    @Published var session: Session?
    @Published var sessionCreated = false
    @Published var users = [User]()
    
    func createSession(name: String) {
        NetworkManager.shared.createSession(name: name) { [weak self] session in
            DispatchQueue.main.async {
                self?.session = session
                if session != nil {
                    self?.sessionCreated = true
                    self?.getProfiles()
                    NetworkManager.shared.listenToSession(id: session!.id, connectionChanged: { _ in}) { session in
                        self?.session = session
                        self?.getProfiles()
                    }
                }
            }
        }
    }
    
    func getProfiles() {
        let group = DispatchGroup()
        var users = [User]()
        session?.members.forEach {
            group.enter()
            NetworkManager.shared.getUser(id: $0) { user in
                if let user = user {
                    users.append(user)
                }
                group.leave()
            }
        }
        group.notify(queue: .main) { [weak self] in
            self?.users = users
        }
    }
    

    static var example: SessionHostViewModel {
        let viewModel = SessionHostViewModel()
        
        viewModel.session = Session.example
        return viewModel
    }
}
