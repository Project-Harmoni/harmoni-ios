//
//  AuthResponse+Extension.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/11/24.
//

import Foundation
import Supabase

extension AuthResponse {
    func toUserDB() -> UserDB {
        UserDB(id: self.user.id, createdAt: self.user.createdAt)
    }
}
