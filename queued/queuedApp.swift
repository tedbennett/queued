//
//  queuedApp.swift
//  queued
//
//  Created by Ted Bennett on 14/03/2021.
//

import SwiftUI
import Firebase

@main
struct queuedApp: App {
    @State private var loading = true
    init() {
        FirebaseApp.configure()
    }
    
    func joinSession(from url: URL) {
        guard url.host == "www.kude.app" || url.host == "kude.app", url.pathComponents.count == 3, url.pathComponents[1] == "session" else {
            return
        }
        SessionManager.shared.joinSession(id: url.pathComponents[2])
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                switch loading {
                    case true: SplashView()
                    case false: ContentView()
                }
            }.onOpenURL { url in
                joinSession(from: url)
            }
            .onAppear {
                UserManager.shared.checkSession() { _ in
                    self.loading = false
                }
            }
        }
    }
}
