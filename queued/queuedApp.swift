//
//  queuedApp.swift
//  queued
//
//  Created by Ted Bennett on 14/03/2021.
//

import SwiftUI
import SpotifyAPI
import FirebaseCore
import FirebaseAuth

@main
struct queuedApp: App {
    init() {
        FirebaseApp.configure()
        Auth.auth().signInAnonymously() { (authResult, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            else {
                UserManager.shared.checkUser()
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView().onOpenURL { url in
                // Handle auth callbacks
                SpotifyHostManager.shared.handleRedirectURL(url)
            }.onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                
            }
        }
    }
}
