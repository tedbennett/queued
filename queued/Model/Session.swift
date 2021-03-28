//
//  Session.swift
//  queued
//
//  Created by Ted Bennett on 27/03/2021.
//

import Foundation

struct Session: Codable {
    var id: String
    var name: String
    var host: User
    var members: [User]
    var queue: [String]
    var createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case host
        case members
        case queue
        case createdAt = "created_at"
    }
}
