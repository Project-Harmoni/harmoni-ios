//
//  DeleteTrack.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/28/24.
//

import Foundation

struct DeleteTrack: Encodable {
    var id: Int?
    
    enum CodingKeys: String, CodingKey {
        case id = "del_id"
    }
}
