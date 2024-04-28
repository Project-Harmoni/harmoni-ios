//
//  EditTag.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/17/24.
//

import Foundation

struct EditTag: Encodable {
    var id: Int?
    var name: String
    var categoryID: Int?
    
    enum CodingKeys: String, CodingKey {
        case id = "param_tag_id"
        case name = "param_tag_name"
        case categoryID = "param_tag_category_id"
    }
}
