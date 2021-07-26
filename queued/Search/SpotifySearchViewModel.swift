//
//  SpotifySearchViewModel.swift
//  queued
//
//  Created by Ted Bennett on 14/03/2021.
//

import SwiftUI

class SpotifySearchViewModel: ObservableObject {
    @Published var songs = [Song]()
    @Published var searchText = "" {
        didSet {
            if searchText.count > 2 {
                getSongsFromSearch()
            }
        }
    }
    func getSongsFromSearch() {
        let encodedSearch = searchText.replacingOccurrences(of: " ", with: "+")
        FirebaseManager.shared.searchSpotify(for: encodedSearch) { songs in
            if let songs = songs {
                DispatchQueue.main.async {
                    self.songs = songs
                }
            }
        }
    }
}
