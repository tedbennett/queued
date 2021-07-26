//
//  User.swift
//  queued
//
//  Created by Ted Bennett on 28/03/2021.
//

import Foundation

struct User: Codable, Identifiable {
    var id: String
    var name: String?
    var imageUrl: String?
    var host: Bool?
    var session: String?
    
}
