//
//  DeleteUserResponse.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/21/24.
//

import Foundation

struct DeleteUserResponse: Decodable {
    var error: String?
    
    enum CodingKeys: String, CodingKey {
        case error
    }
}
