//
//  AppleMusicSearchViewModel.swift
//  queued
//
//  Created by Ted Bennett on 15/03/2021.
//

import SwiftUI
import AppleMusicAPI
import MediaPlayer

class AppleMusicSearchViewModel: ServiceViewModel {
    @Published var songs = [Song]()
    @Published var searchText = ""
    @Published var success = false
    @Published var failure = false
    
    func getSongsFromSearch() {
        AppleMusicAPI.manager.searchCatalog(term: searchText) {tracks, albums, artists, playlists, error in
            guard let tracks = tracks, error == nil else {
                print(error!.localizedDescription)
                return
            }
            DispatchQueue.main.async {
                self.songs = tracks.map { Song($0) }
            }
        }
    }

    func addSongToQueue(_ song: Song) {
        let items = MPMusicPlayerStoreQueueDescriptor(storeIDs: [song.id])
        MPMusicPlayerController.systemMusicPlayer.append(items)
    }
}
