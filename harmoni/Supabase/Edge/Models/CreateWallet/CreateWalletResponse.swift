//
//  CreateWalletResponse.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/21/24.
//

import Foundation

struct CreateWalletResponse: Decodable {
    var publicKey: String?
    var error: String?
    
    enum CodingKeys: String, CodingKey {
        case publicKey = "public_key"
        case error
    }
}
