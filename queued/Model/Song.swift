//
//  Song.swift
//  queued
//
//  Created by Ted Bennett on 28/03/2021.
//

import Foundation
import SpotifyAPI

struct Song: Codable, Identifiable {
    var id: String
    var name: String
    var artist: String
    var album: String
    var imageUrl: String
    var queuedBy: String?
}

extension Song {
    init(from track: SpotifyAPI.Track) {
        id = track.uri
        name = track.name
        artist = track.artists.first?.name ?? "Unknown"
        album = track.album.name
        imageUrl = track.album.images.first?.url ?? ""
    }
}
