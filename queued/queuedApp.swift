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
        SpotifyAPI.manager.authoriseWithClientCredentials(clientId: AppEnvironment.clientId, secretId: AppEnvironment.clientSecret, useKeychain: true) { _ in
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView().onOpenURL { url in
                guard let url = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                    return
                }
                if let code = url.queryItems?.first(where: { $0.name == "code" })?.value {
                    UserManager.shared.authoriseWithSpotify(code: code)
                } else {
                    print("Couldn't obtain code")
                }
            }.onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                
            }
        }
    }
}
