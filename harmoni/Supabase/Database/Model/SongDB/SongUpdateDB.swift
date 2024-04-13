//
//  SongUpdateDB.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/31/24.
//

import Foundation

struct SongUpdateDB: Codable {
    var albumName: String?
    var artistID: String
    var coverImagePath: String?
    var isExplicit: Bool = false
    var payoutThreshold: Int
    var artistPayoutPercentage: Int
    var filePath: String?
    var name: String?
    var streamCount: Int = 0
    var createdAt: String?
    var ordinal: Int
    var isFree: Bool = false
    var payoutType: String?
    
    enum CodingKeys: String, CodingKey {
        case albumName = "album_name"
        case artistID = "artist_id"
        case coverImagePath = "cover_image_path"
        case isExplicit = "is_explicit"
        case payoutThreshold = "payout_threshold"
        case artistPayoutPercentage = "artist_payout_percentage"
        case filePath = "song_file_path"
        case name = "song_name"
        case streamCount = "stream_count"
        case createdAt = "created_at"
        case ordinal
        case isFree = "is_free"
        case payoutType = "payout_type"
    }
}
