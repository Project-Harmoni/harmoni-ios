//
//  ListenerSongLikeDB.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/19/24.
//

import Foundation

struct ListenerSongLikeDB: Codable {
    var listenerID: String?
    var songID: Int?
    
    enum CodingKeys: String, CodingKey {
        case listenerID = "listener_id"
        case songID = "song_id"
    }
}
