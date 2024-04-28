//
//  PlatformConstantsDB.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/15/24.
//

import Foundation

enum PlatformConstantsType: Int {
    case minimumPaymentThreshold = 1
}

struct PlatformConstantsDB: Codable {
    var id: Int
    var name: String
    var value: String
    var type: PlatformConstantsType? {
        .init(rawValue: id)
    }
}

struct PlatformConstants {
    var minimumPaymentThreshold: Int = 0
}
