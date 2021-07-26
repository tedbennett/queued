//
//  ContentView.swift
//  queued
//
//  Created by Ted Bennett on 14/03/2021.
//

import SwiftUI
import BackgroundTasks

struct ContentView: View {
    @StateObject var manager = SessionManager.shared
    @StateObject var userManager = UserManager.shared
    var body: some View {
        HomeView()
            .environmentObject(manager)
            .environmentObject(userManager)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
