//
//  SpotifyManager.swift
//  queued
//
//  Created by Ted Bennett on 01/04/2021.
//

import UIKit
import Combine

class SpotifyManager: ObservableObject {
    static var shared = SpotifyManager()
    private init() {
        
    }
    
    @Published var loggedIn = false
    
    func login() {
        
        let url = URL(string: "https://accounts.spotify.com/authorize?client_id=1e6ef0ef377c443e8ebf714b5b77cad7&response_type=code&redirect_uri=queued://oauth-callback/&scope=user-modify-playback-state%20user-read-recently-played")!
        
        UIApplication.shared.open(url)
    }
    
    func handleRedirectURL(_ url: URL) {
        guard let url = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return
        }
        if let code = url.queryItems?.first(where: { $0.name == "code" })?.value {
            NetworkManager.shared.authoriseWithSpotify(code: code) { success in
                self.loggedIn = success
            }
        } else {
            print("Couldn't obtain code")
        }
    }
}
