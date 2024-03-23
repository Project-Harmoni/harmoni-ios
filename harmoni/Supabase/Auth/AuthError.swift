//
//  AuthError.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/9/24.
//

import Foundation

enum AuthError: Error {
    case unableToGetSession(error: Error)
    case unableToLogout(error: Error)
}
