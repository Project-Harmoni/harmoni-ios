//
//  TagCategoryUpdateDB.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/31/24.
//

import Foundation

struct TagCategoryUpdateDB: Codable {
    var name: String
    var createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case name = "category_name"
        case createdAt = "created_at"
    }
}
