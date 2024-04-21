//
//  InitiateSongPayoutRequest.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/21/24.
//

import Foundation

struct InitiateSongPayoutRequest: Encodable {
    var songID: String
    
    enum CodingKeys: String, CodingKey {
        case songID = "songId"
    }
}
