//
//  SpotifyAuthViewModel.swift
//  queued
//
//  Created by Ted Bennett on 14/03/2021.
//

import SwiftUI
import SpotifyAPI

class SpotifyAuthViewModel: ObservableObject {
    static let shared = SpotifyAuthViewModel()
    private init() {
        initialize()
    }
    
    @Published var authenticated = false
    
    func initialize() {
        SpotifyAPI.manager.initialize(clientId: "1e6ef0ef377c443e8ebf714b5b77cad7", redirectUris: ["queued://oauth-callback/"] , scopes: [.userModifyPlaybackState], useKeychain: false)
    }
    
    func authorize() {
        SpotifyAPI.manager.authorize { success in
            self.authenticated = success
        }
    }
}
