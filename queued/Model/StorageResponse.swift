//
//  StorageResponse.swift
//  queued
//
//  Created by Ted Bennett on 03/04/2021.
//

import Foundation

struct StorageResponse: Codable {
    var url: URL
    var signedRequest: URL
}
