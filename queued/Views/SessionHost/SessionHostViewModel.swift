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
        NetworkManager.shared.createSession(name: name) { [weak self] session in
            DispatchQueue.main.async {
                self?.session = session
                if session != nil {
                    self?.sessionCreated = true
                }
            }
        }
    }
    
    // TODO: Reimplement listening
    
    
    static var example: SessionHostViewModel {
        let viewModel = SessionHostViewModel()
        
        viewModel.session = Session.example
        return viewModel
    }
}
