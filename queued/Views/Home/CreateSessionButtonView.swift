//
//  CreateSessionButtonView.swift
//  queued
//
//  Created by Ted Bennett on 08/08/2021.
//

import SwiftUI

struct CreateSessionButtonView: View {
    @State private var expandSpotifyButton = false
    @State private var loggedInSpotify = false
    
    var logInSpotifyButton: some View {
        HStack {
            Image("spotify_icon")
                .resizable()
                .frame(width: 50, height: 50)
            Text("Log In To Spotify")
                .foregroundColor(.white)
                .font(.title2)
                .fontWeight(.semibold)
                .padding()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(UIColor.systemGray5))
        )
    }
    
    var logoutSpotify: some View {
        HStack {
            ZStack {
                Image("spotify_icon")
                    .resizable()
                    .frame(width: 50, height: 50)
                HStack {
                    Spacer()
                    VStack {
                        Spacer()
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(.white)
                            .padding(0)
                    }
                }
            }.frame(width: 70, height: 70)
                .onTapGesture {
                    withAnimation {
                        expandSpotifyButton.toggle()
                    }
                }
            if expandSpotifyButton {
                Text("Log Out Spotify")
                    .foregroundColor(.white)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding()
                    .transition(.opacity)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(UIColor.systemGray5))
        )
    }
    
    var body: some View {
        if !loggedInSpotify {
            logoutSpotify
        } else {
            if !expandSpotifyButton {
                HStack {
                    
                    
                }
            }
        }
    }
}

struct CreateSessionButtonView_Previews: PreviewProvider {
    static var previews: some View {
        CreateSessionButtonView()
            .preferredColorScheme(.dark)
    }
}
