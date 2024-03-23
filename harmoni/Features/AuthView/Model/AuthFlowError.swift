//
//  AuthFlowError.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/11/24.
//

import Foundation

enum AuthFlowError: LocalizedError {
    case custom(error: String)
    
    var errorDescription: String? {
        switch self {
        case .custom(let error):
            return error
        }
    }
}
