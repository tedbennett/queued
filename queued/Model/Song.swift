//
//  Song.swift
//  queued
//
//  Created by Ted Bennett on 15/03/2021.
//

import Foundation
import SpotifyAPI
import AppleMusicAPI

struct Song: Identifiable {
    var id: String
    var name: String
    var artist: String
    var album: String
    var imageUrl: String?
    var uri: String
    
    init(id: String, name: String, artist: String, album: String, imageUrl: String, uri: String) {
        self.id = id
        self.name = name
        self.artist = artist
        self.album = album
        self.imageUrl = imageUrl
        self.uri = uri
    }
    
    init(_ song: SpotifyAPI.Track) {
        id = song.id
        name = song.name
        artist = song.artists.first?.name ?? "Unknown Artist"
        album = song.album.name
        imageUrl = song.album.images.first?.url
        uri = song.uri
    }
    
    init(_ song: AppleMusicAPI.Song) {
        id = song.id
        name = song.attributes?.name ?? "Unknown Track"
        artist = song.attributes?.artistName ?? "Unknown Artist"
        album = song.attributes?.albumName ?? "Unknown Album"
        imageUrl = song.attributes?.artwork.url
            .replacingOccurrences(of: "{w}", with: String(240))
            .replacingOccurrences(of: "{h}", with: String(240))
        
        uri = song.href?.absoluteString ?? ""
    }
    
    static var example = Song(id: "1", name: "SICKO MODE", artist: "Travis Scott", album: "Astroworld", imageUrl: "", uri: "")
}
