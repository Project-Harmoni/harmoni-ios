//
//  TagDB.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/26/24.
//

import Foundation

struct TagDB: Codable, Identifiable {
    var id: Int?
    var name: String
    var categoryID: Int
    var createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "tag_id"
        case name = "tag_name"
        case categoryID = "tag_category_id"
        case createdAt = "created_at"
    }
}

// MARK: - Updateable

extension TagDB {
    func updateable() -> TagUpdateDB {
        TagUpdateDB(
            name: name,
            categoryID: categoryID,
            createdAt: createdAt
        )
    }
}
