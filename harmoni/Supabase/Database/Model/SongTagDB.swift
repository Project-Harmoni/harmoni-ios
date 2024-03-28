//
//  SongTagDB.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/26/24.
//

import Foundation

struct SongTagDB: Codable {
    var songID: Int8?
    var tagID: Int8?
    var createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case songID = "song_id"
        case tagID = "tag_id"
        case createdAt = "created_at"
    }
}
