//
//  DBService.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/11/24.
//

import Foundation

protocol DBServiceProviding {
    // Get
    
    /// Check if user is admin
    func isAdmin(with id: UUID) async throws -> Bool
    /// Check if user is new
    func isNew(with id: UUID) async throws -> Bool
    /// Get user with `UUID`
    func getUser(with id: UUID) async throws -> UserDB?
    /// Get artist with `UUID`
    func getArtist(with id: UUID) async throws -> ArtistDB?
    /// Get artist name for song
    func getArtistNameForSong(_ song: SongDB) async throws -> String?
    /// Get listener with `UUID`
    func getListener(with id: UUID) async throws -> ListenerDB?
    /// Get tag category
    func getTagCategory(with category: TagCategory) async throws -> TagCategoryDB?
    /// Get all tag categories
    func getTagCategories() async throws -> [TagCategoryDB]?
    /// Get all tags in category
    func tags(in category: TagCategory) async throws -> [TagDB]
    /// Get songs with tags
    func songsWithTags(_ tags: [String]) async throws -> [Song]
    /// Get albums by artist
    func albumsByArtist(with id: UUID) async throws -> [AlbumDB]
    /// Get songs on album
    func songsOnAlbum(with id: Int8) async throws -> [SongDB]
    /// Get latest 20 songs
    func getLatestSongs() async throws -> [Song]
    /// Get tags on album
    func tagsOnAlbum(with id: Int8) async throws -> [Tag]
    /// Check if user with `UUID` has completed birthday and role selection
    func checkRegistrationFinished(for id: UUID) async throws -> Bool
    /// Search by query (albums, artists, songs, tag)
    func search(with query: SearchQuery) async throws -> SearchResults
    /// Advanced search by query (albums, artists, songs, tags)
    func advancedSearch(with query: SearchQuery) async throws -> SearchResults
    
    // Upsert
    
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
    
    // Update
    
    /// Update user in DB
    func update(user: UserDB) async throws
    /// Update listener in DB
    func update(listener: ListenerDB) async throws
    /// Update artist in DB
    func update(artist: ArtistDB) async throws
    /// Update song in DB
    func update(song: SongDB) async throws -> SongDB?
    /// Update album in DB
    func update(album: AlbumDB) async throws -> AlbumDB?
    /// Update tag in DB
    func update(tag: TagDB) async throws -> TagDB?
    /// Udate tag category in DB
    func update(tagCategory: TagCategoryDB) async throws -> TagCategoryDB?
    
    // Delete
    
    // Delete song in DB
    func deleteSong(with id: Int8?) async throws
    func deleteAlbum(with id: Int8?, in storage: StorageProviding) async throws
    func deleteAlbums(with ids: [Int8?], in storage: StorageProviding) async throws
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
    
    func getUser(with id: UUID) async throws -> UserDB? {
        return try await Supabase.shared.client.database.user(with: id)
    }
    
    func getArtist(with id: UUID) async throws -> ArtistDB? {
        return try await Supabase.shared.client.database.artist(with: id)
    }
    
    func getArtistNameForSong(_ song: SongDB) async throws -> String? {
        return try await Supabase.shared.client.database.artistNameForSong(song)
    }
    
    func getListener(with id: UUID) async throws -> ListenerDB? {
        return try await Supabase.shared.client.database.listener(with: id)
    }
    
    func getTagCategory(with category: TagCategory) async throws -> TagCategoryDB? {
        return try await Supabase.shared.client.database.tagCategory(with: category)
    }
    
    func getTagCategories() async throws -> [TagCategoryDB]? {
        return try await Supabase.shared.client.database.tagCategories()
    }
    
    func tags(in category: TagCategory) async throws -> [TagDB] {
        return try await Supabase.shared.client.database.tags(in: category)
    }
    
    func songsWithTags(_ tags: [String]) async throws -> [Song] {
        return try await Supabase.shared.client.database.songsWithTags(tags)
    }
    
    func albumsByArtist(with id: UUID) async throws -> [AlbumDB] {
        return try await Supabase.shared.client.database.albumsByArtist(with: id)
    }
    
    func getLatestSongs() async throws -> [Song] {
        let response = try await Supabase.shared.client.database
            .songs
            .select()
            .order(SongDB.CodingKeys.createdAt.rawValue, ascending: false)
            .limit(20)
            .execute()
        
        let songs = try JSONDecoder().decode([SongDB].self, from: response.data)
        var latest: [Song] = []
        for song in songs {
            guard let artistName = try await getArtistNameForSong(song) else { continue }
            latest.append(.init(details: song, artistName: artistName))
        }
        return latest
    }
    
    func songsOnAlbum(with id: Int8) async throws -> [SongDB] {
        return try await Supabase.shared.client.database.songsOnAlbum(with: id)
    }
    
    func tagsOnAlbum(with id: Int8) async throws -> [Tag] {
        return try await Supabase.shared.client.database.tagsOnAlbum(with: id)
    }
    
    /// Check if user has birthday and role selected
    func checkRegistrationFinished(for id: UUID) async throws -> Bool {
        let user = try await Supabase.shared.client.database.user(with: id)
        guard let user else { return false }
        return user.birthday != nil && user.type != nil
    }
    
    /// Search for results based on query.
    /// Return artists, songs, and albums that match.
    func search(with query: SearchQuery) async throws -> SearchResults {
        return try await Supabase.shared.client.database.search(with: query)
    }
    
    /// Advanced search for results based on query.
    /// Return artists, songs, albums, tags that match.
    func advancedSearch(with query: SearchQuery) async throws -> SearchResults {
        return try await Supabase.shared.client.database.advancedSearch(with: query)
    }
}

// MARK: - DB Service Upsert

extension DBService {
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
}

// MARK: - DB Service Update

extension DBService {
    func update(user: UserDB) async throws {
        _ = try await Supabase.shared.client.database
            .users
            .update(user)
            .eq(UserDB.CodingKeys.id.rawValue, value: user.id)
            .execute()
    }
    
    func update(listener: ListenerDB) async throws {
        _ = try await Supabase.shared.client.database
            .listeners
            .update(listener)
            .eq(ListenerDB.CodingKeys.id.rawValue, value: listener.id)
            .execute()
    }
    
    func update(artist: ArtistDB) async throws {
        _ = try await Supabase.shared.client.database
            .artists
            .update(artist)
            .eq(ArtistDB.CodingKeys.id.rawValue, value: artist.id)
            .execute()
    }
    
    func update(song: SongDB) async throws -> SongDB? {
        guard let id = song.id else { return nil }
        let song: SongDB? = try await Supabase.shared.client.database
            .songs
            .update(song.updateable())
            .eq(SongDB.CodingKeys.id.rawValue, value: Int(id))
            .select()
            .single()
            .execute()
            .value
        
        return song
    }
    
    func update(album: AlbumDB) async throws -> AlbumDB? {
        guard let id = album.id else { return nil }
        let response = try await Supabase.shared.client.database
            .albums
            .update(album.updateable())
            .eq(AlbumDB.CodingKeys.id.rawValue, value: Int(id))
            .select()
            .execute()
        
        let albums = try JSONDecoder().decode([AlbumDB].self, from: response.data)
        return albums.first
    }
    
    func update(tag: TagDB) async throws -> TagDB? {
        guard let id = tag.id else { return nil }
        let response = try await Supabase.shared.client.database
            .tags
            .update(tag.updateable())
            .eq(TagDB.CodingKeys.id.rawValue, value: Int(id))
            .select()
            .execute()
        
        let tags = try JSONDecoder().decode([TagDB].self, from: response.data)
        return tags.first
    }
    
    func update(tagCategory: TagCategoryDB) async throws -> TagCategoryDB? {
        guard let id = tagCategory.id else { return nil }
        let response = try await Supabase.shared.client.database
            .tagCategories
            .update(tagCategory.updateable())
            .eq(TagCategoryDB.CodingKeys.id.rawValue, value: Int(id))
            .select()
            .execute()
        
        let categories = try JSONDecoder().decode([TagCategoryDB].self, from: response.data)
        return categories.first
    }
}

// MARK: - DB Service Delete

extension DBService {
    func deleteSong(with id: Int8?) async throws {
        guard let id else { return }
        _ = try await Supabase.shared.client.database.deleteSong(with: id)
    }
    
    func deleteAlbum(with id: Int8?, in storage: StorageProviding) async throws {
        guard let id else { return }
        _ = try await Supabase.shared.client.database.deleteAlbum(with: id, in: storage)
    }
    
    func deleteAlbums(with ids: [Int8?], in storage: StorageProviding) async throws {
        let ids = ids.compactMap { $0 }
        _ = try await Supabase.shared.client.database.deleteAlbums(with: ids, in: storage)
    }
}
