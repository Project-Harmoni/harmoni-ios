//
//  SongDB.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/26/24.
//

import Foundation

struct SongDB: Codable {
    var id: Int8?
    var albumName: String?
    var artistID: UUID
    var coverImagePath: String?
    var isExplicit: Bool = false
    var payoutThreshold: Int
    var artistPayoutPercentage: Int
    var filePath: String?
    var name: String?
    var streamCount: Int = 0
    var createdAt: Date
    var ordinal: Int
    var isFree: Bool = false
    var payoutType: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "song_id"
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

// MARK: - Initialize from upload details

extension SongDB {
    init(
        track: Track,
        albumName: String,
        artistID: UUID,
        coverImagePath: String,
        filePath: String,
        isExplicit: Bool
    ) {
        self.id = nil
        self.albumName = albumName
        self.artistID = artistID
        self.coverImagePath = coverImagePath
        self.isExplicit = isExplicit
        self.payoutThreshold = track.streamThreshold
        self.artistPayoutPercentage = Int(track.artistPercentage)
        self.filePath = filePath
        self.name = track.name
        self.streamCount = 0
        self.createdAt = .now
        self.ordinal = track.ordinal
        self.isFree = track.isFreeToStream
        self.payoutType = track.payoutType.rawValue
    }
}
