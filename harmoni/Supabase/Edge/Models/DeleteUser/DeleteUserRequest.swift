//
//  DeleteUserRequest.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/21/24.
//

import Foundation

struct DeleteUserRequest: Encodable {
    var userID: String
    
    enum CodingKeys: String, CodingKey {
        case userID = "userId"
    }
}
