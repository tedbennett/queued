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
    @Published var success = false
    @Published var failure = false
    
    func getSongsFromSearch() {
        let encodedSearch = searchText.replacingOccurrences(of: " ", with: "+")
        SpotifyAPI.manager.search(for: "\(encodedSearch)") { (tracks: [SpotifyAPI.Track], url, error) in
            DispatchQueue.main.async {
                self.songs = tracks
            }
        }
    }
    
    func addSongToQueue(_ song: SpotifyAPI.Track) {
        let uri = song.uri
        SpotifyAPI.manager.addTrackToQueue(uri: uri) { success, error in
            
            DispatchQueue.main.async {
                if success {
                    self.success = true
                } else {
                    self.failure = true
                }
            }
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        }
    }
}
