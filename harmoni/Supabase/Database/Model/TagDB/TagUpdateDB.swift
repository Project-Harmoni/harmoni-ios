//
//  TagUpdateDB.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/31/24.
//

import Foundation

struct TagUpdateDB: Codable {
    var name: String
    var categoryID: Int
    var createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case name = "tag_name"
        case categoryID = "tag_category_id"
        case createdAt = "created_at"
    }
}
