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
    var body: some View {
        HomeView()
            .environmentObject(manager)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
