//
//  EditTrack.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/28/24.
//

import Foundation

struct EditTrack: Encodable {
    var id: Int?
    var name: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "param_track_id"
        case name = "param_track_name"
    }
}
