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
    init() {
        FirebaseApp.configure()
        UserManager.shared.checkUser()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    guard url.host == "www.kude.app" || url.host == "kude.app", url.pathComponents.count == 3, url.pathComponents[1] == "session" else {
                        return
                    }
                    SessionManager.shared.joinSession(id: url.pathComponents[2])
                }
        }
    }
}
