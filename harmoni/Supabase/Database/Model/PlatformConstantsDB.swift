//
//  PlatformConstantsDB.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/15/24.
//

import Foundation

enum PlatformConstantsType: Int8 {
    case minimumPaymentThreshold = 1
}

struct PlatformConstantsDB: Codable {
    var id: Int8
    var name: String
    var value: String
    var type: PlatformConstantsType? {
        .init(rawValue: id)
    }
}

struct PlatformConstants {
    var minimumPaymentThreshold: Int = 0
}
