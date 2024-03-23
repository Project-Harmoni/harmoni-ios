//
//  ListenerDB.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/16/24.
//

import Foundation

struct ListenerDB: Codable {
    var id: UUID
    var name: String?
    var email: String?
    var imageURL: String?
    var tokens: Int = 0
    var createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id = "listener_id"
        case name = "listener_name"
        case email
        case imageURL = "image_path"
        case tokens
        case createdAt = "created_at"
    }
}


// MARK: - From UserDB

extension ListenerDB {
    init(from user: UserDB) {
        self.id = user.id
        self.name = user.userName
        self.createdAt = user.createdAt
    }
}
