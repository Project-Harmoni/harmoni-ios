//
//  DeleteTag.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/17/24.
//

import Foundation

struct DeleteTag: Encodable {
    var id: Int?
    
    enum CodingKeys: String, CodingKey {
        case id = "param_tag_id"
    }
}
