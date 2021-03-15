//
//  SpotifySearchViewModel.swift
//  queued
//
//  Created by Ted Bennett on 14/03/2021.
//

import SwiftUI
import SpotifyAPI

protocol ServiceViewModel: ObservableObject {
    var songs: [Song] { get set }
    var searchText: String { get set }
    var success: Bool { get set }
    var failure: Bool { get set }
    
    func getSongsFromSearch()
    func addSongToQueue(_ song: Song)
}

class SpotifySearchViewModel: ServiceViewModel {
    @Published var songs = [Song]()
    @Published var searchText = ""
    @Published var success = false
    @Published var failure = false
    
    func getSongsFromSearch() {
        let encodedSearch = searchText.replacingOccurrences(of: " ", with: "+")
        SpotifyAPI.manager.search(for: "\(encodedSearch)") { (tracks: [SpotifyAPI.Track], url, error) in
            DispatchQueue.main.async {
                self.songs = tracks.map { Song($0) }
            }
        }
    }
    
    func addSongToQueue(_ song: Song) {
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
