//
//  DBService.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/11/24.
//

import Foundation

// TODO: - Clean-up

protocol DBServiceProviding {
    /// Get platform constants
    func getPlatformConstants() async throws -> PlatformConstants?
    /// Check if user is admin
    func isAdmin(with id: UUID) async throws -> Bool
    /// Check if user is new
    func isNew(with id: UUID) async throws -> Bool
    /// Check if user is owner of album
    func does(artist: UUID, own album: Int8) async throws -> Bool
    /// Get user with id
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
    /// Get library
    func getLibrary(for user: String) async throws -> [LibraryItem]
    // Is song in library?
    func isSongInLibrary(_ song: SongDB) async throws -> Bool
    // Is album in library?
    func isAlbumInLibrary(_ album: AlbumDB) async throws -> Bool
    /// Add song to library
    func addSongToLibrary(for user: String, song: SongDB) async throws
    /// Add album to library
    func addAlbumToLibrary(for user: String, album: AlbumDB) async throws
    /// Remove song from library
    func removeSongFromLibrary(_ song: SongDB) async throws
    // Remove album from library
    func removeAlbumFromLibrary(_ album: AlbumDB) async throws
    
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
    

    /// Update artist in DB
    func update(artist: ArtistDB) async throws
    /// Update song in DB
    func update(song: SongDB) async throws -> SongDB?
    /// Update album in DB
    func update(album: AlbumDB) async throws -> AlbumDB?

    // Delete song in DB
    func deleteSong(with id: Int8?) async throws
    func deleteAlbum(with id: Int8?, in storage: StorageProviding) async throws
    func deleteAlbums(with ids: [Int8?], in storage: StorageProviding) async throws
}

struct DBService: DBServiceProviding {
    func getPlatformConstants() async throws -> PlatformConstants? {
        guard let constants = try await Supabase.shared.client.database.getPlatformConstants() else { return nil }
        var platformConstants = PlatformConstants()
        for constant in constants {
            switch constant.type {
            case .minimumPaymentThreshold:
                platformConstants.minimumPaymentThreshold = Int(constant.value) ?? 0
            default:
                continue
            }
        }
        return platformConstants
    }
    
    func isAdmin(with id: UUID) async throws -> Bool {
        let user = try await Supabase.shared.client.database.user(with: id)
        return user?.isAdmin ?? false
    }
    
    func isNew(with id: UUID) async throws -> Bool {
        let user = try await Supabase.shared.client.database.user(with: id)
        return user?.isNew ?? false
    }

    func does(artist: UUID, own album: Int8) async throws -> Bool {
        try await Supabase.shared.client.database.does(artist: artist, own: album)
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
        return try await Supabase.shared.client.database.getLatestSongs()
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

// MARK: - Library

extension DBService {
    func getLibrary(for user: String) async throws -> [LibraryItem] {
        try await Supabase.shared.client.database.getLibrary(for: user)
    }
    
    func isSongInLibrary(_ song: SongDB) async throws -> Bool {
        try await Supabase.shared.client.database.isSongInLibrary(song)
    }
    
    func isAlbumInLibrary(_ album: AlbumDB) async throws -> Bool {
        try await Supabase.shared.client.database.isAlbumInLibrary(album)
    }
    
    func addSongToLibrary(for user: String, song: SongDB) async throws {
        try await Supabase.shared.client.database.addSongToLibrary(for: user, song: song)
    }
    
    func addAlbumToLibrary(for user: String, album: AlbumDB) async throws {
        try await Supabase.shared.client.database.addAlbumToLibrary(for: user, album: album)
    }
    
    func removeSongFromLibrary(_ song: SongDB) async throws {
        try await Supabase.shared.client.database.removeSongFromLibrary(song)
    }
    
    func removeAlbumFromLibrary(_ album: AlbumDB) async throws {
        try await Supabase.shared.client.database.removeAlbumFromLibrary(album)
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
}

// MARK: - DB Service Update

extension DBService {
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
