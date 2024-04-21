//
//  PurchaseTokensRequest.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/21/24.
//

import Foundation

struct PurchaseTokensRequest: Encodable {
    var userID: String
    var tokenQuantity: String
    
    enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case tokenQuantity
    }
}
