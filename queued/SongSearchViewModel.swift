//
//  SongSearchViewModel.swift
//  queued
//
//  Created by Ted Bennett on 14/03/2021.
//

import SwiftUI
import SpotifyAPI

class SongSearchViewModel: ObservableObject {
    @Published var songs = [SpotifyAPI.Track]()
    @Published var searchText = ""
    
    func getSongsFromSearch() {
        SpotifyAPI.manager.search(for: searchText) { (tracks: [SpotifyAPI.Track], url, error) in
            DispatchQueue.main.async {
                self.songs = tracks
            }
        }
    }
    
    func addSongToQueue(_ song: SpotifyAPI.Track) {
        let uri = song.uri
        SpotifyAPI.manager.addTrackToQueue(uri: uri) { success, error in
            print(success)
            print(error)
        }
    }
}
