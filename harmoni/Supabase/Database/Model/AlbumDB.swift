//
//  AlbumDB.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/26/24.
//

import Foundation

struct AlbumDB: Codable, Identifiable {
    var id: Int8?
    var name: String?
    var artistID: String
    var coverImagePath: String?
    var yearReleased: String?
    var totalTracks: Int
    var recordLabel: String?
    var duration: Double?
    var isExplicit: Bool = false
    var createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "album_id"
        case name = "album_name"
        case artistID = "artist_id"
        case coverImagePath = "cover_path"
        case yearReleased = "year_released"
        case totalTracks = "total_tracks"
        case recordLabel = "record_label"
        case duration
        case isExplicit = "is_explicit"
        case createdAt = "created_at"
    }
}
