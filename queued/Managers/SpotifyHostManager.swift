//
//  SpotifyHostManager.swift
//  queued
//
//  Created by Ted Bennett on 28/03/2021.
//

import Foundation
import OAuth2

class SpotifyHostManager: ObservableObject {
    static var shared = SpotifyHostManager()
    private init() {}
    private var authClient: OAuth2CodeGrant?
    
    
    @Published var token: String?
    
    func handleRedirectURL(_ url: URL) {
        authClient?.handleRedirectURL(url)
    }
    
    func login() {
        authClient = OAuth2CodeGrant(settings: [
            "client_id": "1e6ef0ef377c443e8ebf714b5b77cad7",
            "authorize_uri": "https://accounts.spotify.com/authorize",
            "token_uri": "https://accounts.spotify.com/api/token",
            "redirect_uris": ["queued://oauth-callback/"],
            "use_pkce": true,
            "scope": "user-modify-playback-state%20user-read-recently-played",
            "keychain": true,
        ] as OAuth2JSON)
        authClient!.authorize(callback: {authParameters, error in
            if authParameters != nil {
                self.token = self.authClient?.accessToken
            }
            else {
                print("Authorization was canceled or went wrong: \(String(describing: error))")
                if error?.description == "Refresh token revoked" {
                    self.authClient!.forgetTokens()
                }
            }
        })
    }
}
