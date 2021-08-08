//
//  HomeViewModel.swift
//  queued
//
//  Created by Ted Bennett on 05/08/2021.
//

import Foundation
import Combine
import BetterSafariView

let AUTHORISE_SPOTIFY_URL = URL(string: "https://accounts.spotify.com/authorize?client_id=1e6ef0ef377c443e8ebf714b5b77cad7&response_type=code&redirect_uri=queued://oauth-callback/&scope=user-read-private%20user-modify-playback-state%20user-read-recently-played%20user-read-playback-state&show_dialog=true")!

class HomeViewModel: ObservableObject {
    @Published var startingWebAuthSession = false
    @Published var creatingSession = false
    
    var webAuthSession: WebAuthenticationSession {
        WebAuthenticationSession(url: AUTHORISE_SPOTIFY_URL,
            callbackURLScheme: "queued") { callbackURL, error in
            guard let callbackURL = callbackURL, error == nil,
                  let url = URLComponents(url: callbackURL, resolvingAgainstBaseURL: true),
                  let code = url.queryItems?.first(where: { $0.name == "code" })?.value else {
                print(error.debugDescription)
                return
            }
            UserManager.shared.authoriseWithSpotify(code: code)
        }
    }
    
    func logInToSpotify() {
        startingWebAuthSession.toggle()
    }
    
    func logOutSpotify() {
        UserManager.shared.logoutFromSpotify()
    }
    
    func createSession() {
        let userName = UserManager.shared.user.name
        let sessionName = userName == nil ? "New Session" : "\(userName!)'s Session"
        SessionManager.shared.createSession(name: sessionName)
    }
}
