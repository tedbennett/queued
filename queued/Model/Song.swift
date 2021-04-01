//
//  Song.swift
//  queued
//
//  Created by Ted Bennett on 28/03/2021.
//

import Foundation

struct Song: Codable, Identifiable {
    var id: String
    var name: String
    var artist: String
    var album: String
    var imageUrl: String
    var queuedBy: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case artist
        case album
        case imageUrl = "image_url"
        case queuedBy = "queued_by"
    }
}
