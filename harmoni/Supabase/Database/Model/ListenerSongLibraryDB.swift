//
//  ListenerSongLibraryDB.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/14/24.
//

import Foundation

struct ListenerSongLibraryDB: Codable {
    var id: Int?
    var listenerID: String?
    var songID: Int?
    var addedOn: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case listenerID = "listener_id"
        case songID = "song_id"
        case addedOn = "added_on"
    }
}
