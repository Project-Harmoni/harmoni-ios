//
//  ArtistDB.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/16/24.
//

import Foundation

struct ArtistDB: Codable {
    var id: UUID
    var name: String?
    var formationDate: Date?
    var disbandmentDate: Date?
    var imageURL: String?
    var socialLinkURL: String?
    var biography: String?
    var genre: String?
    var tokens: Int = 0
    var createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id = "artist_id"
        case name = "artist_name"
        case formationDate = "formation_date"
        case disbandmentDate = "disbandment_date"
        case imageURL = "image_path"
        case socialLinkURL = "social_media_link"
        case biography
        case genre
        case tokens
        case createdAt = "created_at"
    }
}

// MARK: - From UserDB

extension ArtistDB {
    init(from user: UserDB) {
        self.id = user.id
        self.name = user.userName
        self.createdAt = user.createdAt
    }
}
