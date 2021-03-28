//
//  Song.swift
//  queued
//
//  Created by Ted Bennett on 28/03/2021.
//

import Foundation

struct Song: Codable {
    var id: String
    var uri: String
    var name: String
    var artist: String
    var album: String
    var imageUrl: String
    var queuedBy: User?
    
    enum CodingKeys: String, CodingKey {
        case id
        case uri
        case name
        case artist
        case album
        case imageUrl = "image_url"
        case queuedBy = "queued_by"
    }
}
