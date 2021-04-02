//
//  ProfileViewModel.swift
//  queued
//
//  Created by Ted Bennett on 02/04/2021.
//

import UIKit

class ProfileViewModel: ObservableObject {
    
    func loginToSpotify() {
        let url = URL(string: "https://accounts.spotify.com/authorize?client_id=\(AppEnvironment.clientId)&response_type=code&redirect_uri=queued://oauth-callback/&scope=user-modify-playback-state%20user-read-recently-played")!
        
        UIApplication.shared.open(url)
    }
    
    func logoutFromSpotify() {
        UserManager.shared.logoutFromSpotify()
    }
}
