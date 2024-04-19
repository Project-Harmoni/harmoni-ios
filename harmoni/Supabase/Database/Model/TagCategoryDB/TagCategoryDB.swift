//
//  TagCategoryDB.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/26/24.
//

import Foundation

struct TagCategoryDB: Codable, Identifiable {
    var id: Int8?
    var name: String
    var createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "category_id"
        case name = "category_name"
        case createdAt = "created_at"
    }
}

// MARK: - To TagCategory

extension TagCategoryDB {
    func toCategory() -> TagCategory? {
        TagCategory(rawValue: name)
    }
}
