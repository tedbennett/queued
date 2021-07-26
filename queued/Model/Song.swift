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
    var queuedBy: String?
    
}
