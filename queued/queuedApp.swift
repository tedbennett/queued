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
