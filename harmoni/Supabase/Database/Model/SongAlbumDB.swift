//
//  SongAlbumDB.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/26/24.
//

import Foundation

struct SongAlbumDB: Codable {
    var songID: Int8?
    var albumID: Int8?
    var createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case songID = "song_id"
        case albumID = "album_id"
        case createdAt = "created_at"
    }
}
