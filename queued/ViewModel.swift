//
//  ViewModel.swift
//  queued
//
//  Created by Ted Bennett on 14/03/2021.
//

import SwiftUI
import SpotifyAPI

class ViewModel: ObservableObject {
    static let shared = ViewModel()
    private init() {
        initialize()
    }
    
    @Published var authenticated = false
    
    func initialize() {
        SpotifyAPI.manager.initialize(clientId: "1e6ef0ef377c443e8ebf714b5b77cad7", redirectUris: ["queued://oauth-callback/"] , scopes: [.playlistModifyPrivate, .playlistModifyPublic])
    }
    func authorize() {
        SpotifyAPI.manager.authorize { success in
            self.authenticated = success
        }
    }
}
