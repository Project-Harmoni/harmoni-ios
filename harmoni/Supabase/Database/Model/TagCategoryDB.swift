//
//  TagCategoryDB.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/26/24.
//

import Foundation

struct TagCategoryDB: Codable {
    var id: Int8?
    var name: String
    var createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id = "category_id"
        case name = "category_name"
        case createdAt = "created_at"
    }
}
