//
//  TagDB.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/26/24.
//

import Foundation

struct TagDB: Codable {
    var id: Int8?
    var name: String
    var categoryID: Int8
    var createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id = "tag_id"
        case name = "tag_name"
        case categoryID = "tag_category_id"
        case createdAt = "created_at"
    }
}
