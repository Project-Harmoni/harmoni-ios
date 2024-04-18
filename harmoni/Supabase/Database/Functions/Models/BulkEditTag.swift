//
//  BulkEditTag.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/17/24.
//

import Foundation

struct BulkEditTag: Encodable {
    var ids: [Int8]?
    var names: [String]
    var categoryIDs: [Int8]?
    
    enum CodingKeys: String, CodingKey {
        case ids = "param_tag_id"
        case names = "param_tag_name"
        case categoryIDs = "param_tag_category"
    }
}
