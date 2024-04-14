//
//  UserProvider.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/16/24.
//

import Foundation
import Supabase

protocol UserProviding {
    var isAdmin: Bool { get async }
    var isArtist: Bool { get async }
    var isNew: Bool {get async }
    var isAdult: Bool { get async }
    var currentUser: User? { get async }
    var currentUserID: UUID? { get async }
}

struct UserProvider: UserProviding {
    private let database: DBServiceProviding = DBService()
    
    var isAdmin: Bool {
        get async {
            do {
                guard let currentUser = await AuthManager.shared.currentUser else { return false }
                return try await database.isAdmin(with: currentUser.id)
            } catch {
                dump(error)
                return false
            }
        }
    }
    
    var isArtist: Bool {
        get async {
            do {
                guard let currentUser = await AuthManager.shared.currentUser else { return false }
                return try await database.getArtist(with: currentUser.id) != nil
            } catch {
                dump(error)
                return false
            }
        }
    }
    
    var isNew: Bool {
        get async {
            do {
                guard let currentUser = await AuthManager.shared.currentUser else { return false }
                return try await database.isNew(with: currentUser.id)
            } catch {
                dump(error)
                return false
            }
        }
    }
    
    var isAdult: Bool {
        get async {
            do {
                guard let currentUser = await AuthManager.shared.currentUser else { return false }
                guard let user = try await database.getUser(with: currentUser.id) else { return false }
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-mm-dd"
                guard let birthday = user.birthday, let birthdate = dateFormatter.date(from: birthday) else { return false }
                // get 18 years ago: https://stackoverflow.com/a/39718464
                guard let adultYearThreshold = Calendar.current.date(byAdding: .year, value: -18, to: .now) else { return false }
                return birthdate <= adultYearThreshold
            } catch {
                dump(error)
                return false
            }
        }
    }
    
    var currentUser: User? {
        get async {
            await AuthManager.shared.currentUser
        }
    }
    
    var currentUserID: UUID? {
        get async {
            await AuthManager.shared.currentUser?.id
        }
    }
}
