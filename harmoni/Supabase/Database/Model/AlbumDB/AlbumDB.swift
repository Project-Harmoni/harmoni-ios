//
//  AlbumDB.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/26/24.
//

import Foundation

struct AlbumDB: Codable, Identifiable, Equatable {
    var id: Int?
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

extension AlbumDB {
    /// Name of image in storage bucket
    var coverImageStorageBucketName: String? {
        if let coverImagePath, let url = URL(string: coverImagePath) {
            return url.lastPathComponent
        } else {
            return nil
        }
    }
    
    var coverImageData: Data? {
        get throws {
            guard let coverImagePath else { return nil }
            guard let url = URL(string: coverImagePath) else { return nil }
            return try Data(contentsOf: url)
        }
    }
}

// MARK: - Updateable

extension AlbumDB {
    func updateable() -> AlbumUpdateDB {
        AlbumUpdateDB(
            name: name,
            artistID: artistID,
            coverImagePath: coverImagePath,
            yearReleased: yearReleased,
            totalTracks: totalTracks,
            recordLabel: recordLabel,
            duration: duration,
            isExplicit: isExplicit,
            createdAt: createdAt
        )
    }
}
