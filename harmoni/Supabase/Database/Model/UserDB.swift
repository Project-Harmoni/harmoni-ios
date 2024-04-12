//
//  UserDB.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/11/24.
//

import Foundation

struct UserDB: Codable {
    var id: UUID
    var userName: String?
    var type: String?
    var publicKey: String?
    var privateKey: String?
    var isAdmin: Bool = false
    var createdAt: Date?
    var birthday: String?
    var isNew: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id = "user_id"
        case userName = "user_name"
        case type = "user_type"
        case publicKey = "public_key"
        case privateKey = "private_key"
        case isAdmin = "is_admin"
        case createdAt = "created_at"
        case birthday
        case isNew = "is_new"
    }
}
