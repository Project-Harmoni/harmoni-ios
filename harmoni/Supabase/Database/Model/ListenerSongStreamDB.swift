//
//  ListenerSongStreamDB.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/25/24.
//

import Foundation

struct ListenerSongStreamDB: Codable {
    var id: Int?
    var listenerID: String?
    var songID: Int?
    
    enum CodingKeys: String, CodingKey {
        case id = "listener_song_stream_id"
        case listenerID = "listener_id"
        case songID = "song_id"
    }
}
