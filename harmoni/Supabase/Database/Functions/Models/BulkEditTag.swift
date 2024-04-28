//
//  BulkEditTag.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/17/24.
//

import Foundation

struct BulkEditTag: Encodable {
    var ids: [Int]?
    var names: [String]
    var categoryIDs: [Int]?
    
    enum CodingKeys: String, CodingKey {
        case ids = "param_tag_id"
        case names = "param_tag_name"
        case categoryIDs = "param_tag_category"
    }
}
