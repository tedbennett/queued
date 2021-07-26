//
//  NameView.swift
//  queued
//
//  Created by Ted Bennett on 13/06/2021.
//

import SwiftUI

struct NameView: View {
    @State private var name = ""
    
    var body: some View {
        NavigationView {
            VStack {
                enterNameField
                logInToSpotifyButton
            }.navigationTitle("Welcome to Kude")
        }
    }
    
    var enterNameField: some View {
        VStack {
            Text("Enter your name")
            TextField("", text: $name)
            Divider().padding(.horizontal)
            Text("Your name will appear in sessions you join")
                .font(.footnote)
                .foregroundColor(.gray)
        }
    }
    
    var logInToSpotifyButton: some View {
        VStack {
            Image("spotify_icon")
                .resizable()
                .frame(width: 100, height: 100)
        }
    }
}

struct NameView_Previews: PreviewProvider {
    static var previews: some View {
        NameView()
    }
}
