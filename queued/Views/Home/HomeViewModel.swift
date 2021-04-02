//
//  HomeViewModel.swift
//  queued
//
//  Created by Ted Bennett on 02/04/2021.
//

import Combine
import Dispatch

class HomeViewModel: ObservableObject {
    @Published var failedToFindSession = false
    
    func findAndJoinSession(key: String) {
        NetworkManager.shared.getSession(key: key) { session in
            if let session = session {
                SessionManager.shared.joinSession(id: session.id)
            } else {
                DispatchQueue.main.async { [weak self] in
                    self?.failedToFindSession = true
                }
            }
        }
    }
}
