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
    var host: String
    var members: [String]
    var queue: [Song]
    var createdAt: Date
    
    var currentlyPlaying: Int?
    var frequency: Int? // Number of queues per 10 minutes
    
    var url: URL {
        return URL(string: "https://www.kude.app/session/\(id)")!
    }
    
    static let example = Session(id: "", name: "New Session", host: "host-id", members: ["James", "Donny"], queue: [], createdAt: Date())
}
