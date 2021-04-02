//
//  queuedApp.swift
//  queued
//
//  Created by Ted Bennett on 14/03/2021.
//

import SwiftUI
import SpotifyAPI

@main
struct queuedApp: App {
    init() {
        UserManager.shared.checkUser()
        SpotifyAPI.manager.authoriseWithClientCredentials(clientId: "1e6ef0ef377c443e8ebf714b5b77cad7", secretId: "3dd29adb40ee40e2a2690f659ad3bbdb", useKeychain: true) { _ in
            print("woah")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView().onOpenURL { url in
                SpotifyManager.shared.handleRedirectURL(url)
            }.onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                
            }
        }
    }
}
