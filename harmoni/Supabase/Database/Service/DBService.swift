//
//  DBService.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/11/24.
//

import Foundation

protocol DBServiceProviding {
    /// Check if user is admin
    func isAdmin(with id: UUID) async throws -> Bool
    /// Get artist with `UUID`
    func getArtist(with id: UUID) async throws -> ArtistDB?
    /// Get listener with `UUID`
    func getListener(with id: UUID) async throws -> ListenerDB?
    /// Check if user with `UUID` has completed birthday and role selection
    func checkRegistrationFinished(for id: UUID) async throws -> Bool
    /// Upsert (update or insert) ) user in DB
    func upsert(user: UserDB) async throws
    /// Upsert (update or insert) ) listener in DB
    func upsert(listener: ListenerDB) async throws
    /// Upsert (update or insert) ) artist in DB
    func upsert(artist: ArtistDB) async throws
}

struct DBService: DBServiceProviding {
    func isAdmin(with id: UUID) async throws -> Bool {
        let user = try await Supabase.shared.client.database.user(with: id)
        return user?.isAdmin ?? false
    }
    
    func getArtist(with id: UUID) async throws -> ArtistDB? {
        return try await Supabase.shared.client.database.artist(with: id)
    }
    
    func getListener(with id: UUID) async throws -> ListenerDB? {
        return try await Supabase.shared.client.database.listener(with: id)
    }
    
    func upsert(user: UserDB) async throws {
        _ = try await Supabase.shared.client.database
            .users
            .upsert(user)
            .execute()
    }
    
    func upsert(listener: ListenerDB) async throws {
        _ = try await Supabase.shared.client.database
            .listeners
            .upsert(listener)
            .execute()
    }
    
    func upsert(artist: ArtistDB) async throws {
        _ = try await Supabase.shared.client.database
            .artists
            .upsert(artist)
            .execute()
    }
    
    /// Check if user has birthday and role selected
    func checkRegistrationFinished(for id: UUID) async throws -> Bool {
        let user = try await Supabase.shared.client.database.user(with: id)
        guard let user else { return false }
        return user.birthday != nil && user.type != nil
    }
}
