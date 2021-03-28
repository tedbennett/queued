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
    
    func createSession(name: String) {
        guard let token = SpotifyHostManager.shared.token else {
            return
        }
        FirebaseManager.shared.createSession(name: name, token: token) { [weak self] session in
            self?.session = session
            self?.sessionCreated = session != nil
        }
    }
    
    
    static var example: SessionHostViewModel {
        let viewModel = SessionHostViewModel()
        let session = Session(id: "", name: "New Session", host: User(id: "", name: "Host 1"), members: [], queue: [], createdAt: Date())
        viewModel.session = session
        return viewModel
    }
}
