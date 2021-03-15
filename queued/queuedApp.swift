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
    var body: some Scene {
        WindowGroup {
            ContentView().onOpenURL { url in
                // Handle auth callbacks
                SpotifyAPI.manager.handleRedirect(url: url)
            }
        }
    }
}
