//
//  PlaySongResponse.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/21/24.
//

import Foundation

struct PlaySongResponse: Decodable {
    var error: String?
    
    enum CodingKeys: String, CodingKey {
        case error
    }
}
