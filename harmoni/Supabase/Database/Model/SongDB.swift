//
//  SongDB.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/26/24.
//

import Foundation

struct SongDB: Codable, Identifiable, Hashable {
    var id: Int8?
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
        self.artistID = artistID.uuidString
        self.coverImagePath = coverImagePath
        self.isExplicit = isExplicit
        self.payoutThreshold = track.streamThreshold
        self.artistPayoutPercentage = Int(track.artistPercentage)
        self.filePath = filePath
        self.name = track.name
        self.streamCount = 0
        self.ordinal = track.ordinal
        self.isFree = track.isFreeToStream
        self.payoutType = track.payoutType.rawValue
    }
}

// MARK: - To Track

extension SongDB {
    func toTrack() -> Track? {
        guard let payoutType else { return nil }
        guard let trackPayoutType = TrackPayoutType(rawValue: payoutType) else { return nil }
        guard let name else { return nil }
        guard let filePath else { return nil }
        guard let url = URL(string: filePath) else { return nil }
        return Track(
            ordinal: ordinal,
            url: url,
            name: name,
            fileExtension: ".\(url.pathExtension)",
            artistPercentage: CGFloat(artistPayoutPercentage),
            streamThreshold: payoutThreshold,
            isFreeToStream: isFree,
            payoutType: trackPayoutType
        )
    }
}

// MARK: - Mock

extension SongDB {
    static var mock: Self {
        SongDB(
            track: .init(
                url: URL(string: "www.apple.com")!,
                name: "Hit Song",
                fileExtension: ".mp3"
            ),
            albumName: "Coolest Album",
            artistID: .init(),
            coverImagePath: "",
            filePath: "",
            isExplicit: false
        )
    }
}
