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
    /// Check if user is new
    func isNew(with id: UUID) async throws -> Bool
    /// Get artist with `UUID`
    func getArtist(with id: UUID) async throws -> ArtistDB?
    /// Get listener with `UUID`
    func getListener(with id: UUID) async throws -> ListenerDB?
    /// Get tag category
    func getTagCategory(with category: TagCategory) async throws -> TagCategoryDB?
    /// Get albums by artist
    func albums(by artist: UUID) async throws -> [AlbumDB]
    /// Get songs on album
    func songs(on album: Int8) async throws -> [SongDB]
    /// Get tags for song
    func tags(for song: Int8) async throws -> [TagDB]
    /// Check if user with `UUID` has completed birthday and role selection
    func checkRegistrationFinished(for id: UUID) async throws -> Bool
    /// Upsert (update or insert) user in DB
    func upsert(user: UserDB) async throws
    /// Upsert (update or insert) listener in DB
    func upsert(listener: ListenerDB) async throws
    /// Upsert (update or insert) artist in DB
    func upsert(artist: ArtistDB) async throws
    /// Upsert (update or insert) song in DB
    func upsert(song: SongDB) async throws -> SongDB?
    /// Upsert (update or insert) album in DB
    func upsert(album: AlbumDB) async throws -> AlbumDB?
    /// Upsert (update or insert) song/album association in DB
    func upsert(songAlbum: SongAlbumDB) async throws -> SongAlbumDB?
    /// Upsert (update or insert) song/tag association in DB
    func upsert(songTag: SongTagDB) async throws -> SongTagDB?
    /// Upsert (update or insert) tag in DB
    func upsert(tag: TagDB) async throws -> TagDB?
    /// Upsert (update or insert) tag category in DB
    func upsert(tagCategory: TagCategoryDB) async throws -> TagCategoryDB?
}

struct DBService: DBServiceProviding {
    func isAdmin(with id: UUID) async throws -> Bool {
        let user = try await Supabase.shared.client.database.user(with: id)
        return user?.isAdmin ?? false
    }
    
    func isNew(with id: UUID) async throws -> Bool {
        let user = try await Supabase.shared.client.database.user(with: id)
        return user?.isNew ?? false
    }
    
    func getArtist(with id: UUID) async throws -> ArtistDB? {
        return try await Supabase.shared.client.database.artist(with: id)
    }
    
    func getListener(with id: UUID) async throws -> ListenerDB? {
        return try await Supabase.shared.client.database.listener(with: id)
    }
    
    func getUser(with id: UUID) async throws -> UserDB? {
        return try await Supabase.shared.client.database.user(with: id)
    }
    
    func getTagCategory(with category: TagCategory) async throws -> TagCategoryDB? {
        return try await Supabase.shared.client.database.tagCategory(with: category)
    }
    
    func albums(by artist: UUID) async throws -> [AlbumDB] {
        return try await Supabase.shared.client.database.albums(by: artist)
    }
    
    func songs(on album: Int8) async throws -> [SongDB] {
        return try await Supabase.shared.client.database.songs(on: album)
    }
    
    func tags(for song: Int8) async throws -> [TagDB] {
        return try await Supabase.shared.client.database.tags(for: song)
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
    
    func upsert(song: SongDB) async throws -> SongDB? {
        let response = try await Supabase.shared.client.database
            .songs
            .upsert(song)
            .execute()
        
        let songs = try JSONDecoder().decode([SongDB].self, from: response.data)
        return songs.first
    }
    
    func upsert(album: AlbumDB) async throws -> AlbumDB? {
        let response = try await Supabase.shared.client.database
            .albums
            .upsert(album)
            .execute()
        
        let albums = try JSONDecoder().decode([AlbumDB].self, from: response.data)
        return albums.first
    }
    
    func upsert(songAlbum: SongAlbumDB) async throws -> SongAlbumDB? {
        let response = try await Supabase.shared.client.database
            .songAlbums
            .upsert(songAlbum)
            .execute()
        
        let songAlbums = try JSONDecoder().decode([SongAlbumDB].self, from: response.data)
        return songAlbums.first
    }
    
    func upsert(songTag: SongTagDB) async throws -> SongTagDB? {
        let response = try await Supabase.shared.client.database
            .songTags
            .upsert(songTag)
            .execute()
        
        let songTags = try JSONDecoder().decode([SongTagDB].self, from: response.data)
        return songTags.first
    }
    
    func upsert(tag: TagDB) async throws -> TagDB? {
        let response = try await Supabase.shared.client.database
            .tags
            .upsert(tag)
            .execute()
        
        let tags = try JSONDecoder().decode([TagDB].self, from: response.data)
        return tags.first
    }
    
    func upsert(tagCategory: TagCategoryDB) async throws -> TagCategoryDB? {
        let response = try await Supabase.shared.client.database
            .tagCategories
            .upsert(tagCategory)
            .execute()
        
        let tagCategories = try JSONDecoder().decode([TagCategoryDB].self, from: response.data)
        return tagCategories.first
    }
    
    /// Check if user has birthday and role selected
    func checkRegistrationFinished(for id: UUID) async throws -> Bool {
        let user = try await Supabase.shared.client.database.user(with: id)
        guard let user else { return false }
        return user.birthday != nil && user.type != nil
    }
}
