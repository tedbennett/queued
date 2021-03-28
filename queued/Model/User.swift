//
//  User.swift
//  queued
//
//  Created by Ted Bennett on 28/03/2021.
//

import Foundation

struct User: Codable {
    var id: String
    var name: String?
    var imageUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case imageUrl = "image_url"
    }
}
