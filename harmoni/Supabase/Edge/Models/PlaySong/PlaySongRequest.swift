//
//  PlaySongRequest.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/21/24.
//

import Foundation

struct PlaySongRequest: Encodable {
    var songID: String
    var userID: String
    
    enum CodingKeys: String, CodingKey {
        case songID = "songId"
        case userID = "userId"
    }
}
