//
//  SpotifySearchViewModel.swift
//  queued
//
//  Created by Ted Bennett on 14/03/2021.
//

import SwiftUI
import SpotifyAPI

class SpotifySearchViewModel: ObservableObject {
    @Published var songs = [Song]()
    @Published var searchText = ""
    @Published var success = false
    @Published var failure = false
    
    var sessionId: String
    
    init(sessionId: String) {
        self.sessionId = sessionId
    }
    
    func getSongsFromSearch() {
        let encodedSearch = searchText.replacingOccurrences(of: " ", with: "+")
        SpotifyAPI.manager.search(for: "\(encodedSearch)") { (tracks: [SpotifyAPI.Track], url, error) in
            DispatchQueue.main.async {
                self.songs = tracks.map { Song(from: $0)}
            }
        }
    }
    
    func addSongToQueue(_ song: Song) {
        NetworkManager.shared.addSongToQueue(song, sessionId: sessionId) { [weak self] success in
            DispatchQueue.main.async {
                if success {
                    self?.success = true
                } else {
                    self?.failure = true
                }
            }
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        }
    }
}
