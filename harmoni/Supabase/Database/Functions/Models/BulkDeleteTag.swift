//
//  BulkDeleteTag.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/17/24.
//

import Foundation

struct BulkDeleteTag: Encodable {
    var id: [Int8]?
    
    enum CodingKeys: String, CodingKey {
        case id = "param_tag_id"
    }
}
