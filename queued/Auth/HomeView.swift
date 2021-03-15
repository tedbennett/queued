//
//  HomeView.swift
//  queued
//
//  Created by Ted Bennett on 14/03/2021.
//

import SwiftUI

struct HomeView: View {
    @StateObject var spotifyViewModel = SpotifyAuthViewModel.shared
    @StateObject var appleMusicViewModel = AppleMusicAuthViewModel.shared
    
    var body: some View {
        NavigationView {
            if spotifyViewModel.authenticated {
                SongSearchView(viewModel: SpotifySearchViewModel())
            } else if appleMusicViewModel.authenticated {
                SongSearchView(viewModel: AppleMusicSearchViewModel())
            } else {
                VStack {
                    Button(action: {
                        spotifyViewModel.authorize()
                    }, label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10).foregroundColor(.gray).frame(width: 250, height: 100)
                            Text("Log In to Spotify").foregroundColor(.white).font(.title2).padding()
                        }
                    }).padding()
                    Button(action: {
                        appleMusicViewModel.authorize()
                    }, label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10).foregroundColor(.gray).frame(width: 250, height: 100)
                            Text("Log In to Apple Music").foregroundColor(.white).font(.title2).padding()
                        }
                    }).padding()   
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
