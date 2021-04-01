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
    var key: String
    var host: String
    var members: [String]
    var queue: [Song]
    var createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case key
        case host
        case members
        case queue
        case createdAt = "created_at"
    }
    
    static let example = Session(id: "", name: "New Session", key: "ABCDEF", host: "host-id", members: [], queue: [], createdAt: Date())
}
