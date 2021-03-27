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
    var hostId: String
    var members: [String]
    var queue: [String]
    var createdAt: Date
}
