//
//  User+Extension.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/13/24.
//

import Foundation
import Supabase

extension User {
    func toUserDB() -> UserDB {
        var user = UserDB(id: self.id)
        user.createdAt = self.createdAt
        return user
    }
}
