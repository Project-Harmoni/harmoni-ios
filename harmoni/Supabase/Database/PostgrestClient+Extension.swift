//
//  PostgrestClient+Extension.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/11/24.
//

import Foundation
import Supabase

fileprivate enum DatabaseTables: String {
    case users = "users"
    case artists = "artists"
    case groups = "groups"
    case artistGroup = "artist_group"
    case albums = "albums"
    case songs = "songs"
    case listeners = "listeners"
    case tags = "tags"
    case tagCategory = "tag_category"
    case listenerSongStream = "listener_song_stream"
    case listenerSongLikes = "listener_song_likes"
    case songTag = "song_tag"
    case songAlbum = "song_album"
}

// MARK: - Tables

extension PostgrestClient {
    private func getTable(with name: String) async -> PostgrestQueryBuilder {
        await Supabase.shared.client.database.from(name)
    }
    
    var users: PostgrestQueryBuilder {
        get async { await getTable(with: DatabaseTables.users.rawValue) }
    }
    
    var artists: PostgrestQueryBuilder {
        get async { await getTable(with: DatabaseTables.artists.rawValue) }
    }
    
    var groups: PostgrestQueryBuilder {
        get async { await getTable(with: DatabaseTables.groups.rawValue) }
    }
    
    var artistGroup: PostgrestQueryBuilder {
        get async { await getTable(with: DatabaseTables.artistGroup.rawValue) }
    }
    
    var albums: PostgrestQueryBuilder {
        get async { await getTable(with: DatabaseTables.albums.rawValue) }
    }
    
    var songs: PostgrestQueryBuilder {
        get async { await getTable(with: DatabaseTables.songs.rawValue) }
    }
    
    var listeners: PostgrestQueryBuilder {
        get async { await getTable(with: DatabaseTables.listeners.rawValue) }
    }
    
    var tags: PostgrestQueryBuilder {
        get async { await getTable(with: DatabaseTables.tags.rawValue) }
    }
    
    var tagCategories: PostgrestQueryBuilder {
        get async { await getTable(with: DatabaseTables.tagCategory.rawValue) }
    }
    
    var listenerSongStreams: PostgrestQueryBuilder {
        get async { await getTable(with: DatabaseTables.listenerSongStream.rawValue) }
    }
    
    var listenerSongLikes: PostgrestQueryBuilder {
        get async { await getTable(with: DatabaseTables.listenerSongLikes.rawValue) }
    }
    
    var songTags: PostgrestQueryBuilder {
        get async { await getTable(with: DatabaseTables.songTag.rawValue) }
    }
    
    var songAlbums: PostgrestQueryBuilder {
        get async { await getTable(with: DatabaseTables.songAlbum.rawValue) }
    }
}

// MARK: - Common Ops

extension PostgrestClient {
    func user(with id: UUID) async throws -> UserDB? {
        let users: [UserDB] = try await users
            .select()
            .eq(UserDB.CodingKeys.id.rawValue, value: id)
            .execute()
            .value
        return users.first
    }
    
    func listener(with id: UUID) async throws -> ListenerDB? {
        let listeners: [ListenerDB] = try await listeners
            .select()
            .eq(ListenerDB.CodingKeys.id.rawValue, value: id)
            .execute()
            .value
        return listeners.first
    }
    
    func artist(with id: UUID) async throws -> ArtistDB? {
        let artists: [ArtistDB] = try await artists
            .select()
            .eq(ArtistDB.CodingKeys.id.rawValue, value: id)
            .execute()
            .value
        return artists.first
    }
    
    func tagCategory(with category: TagCategory) async throws -> TagCategoryDB? {
        let tagCategories: [TagCategoryDB] = try await tagCategories
            .select()
            .eq(TagCategoryDB.CodingKeys.name.rawValue, value: category.rawValue)
            .execute()
            .value
        return tagCategories.first
    }
    
    func albums(by artist: UUID) async throws -> [AlbumDB] {
        let albums: [AlbumDB] = try await albums
            .select()
            .eq(AlbumDB.CodingKeys.artistID.rawValue, value: artist)
            .execute()
            .value
        return albums
    }
    
    func songs(on album: Int8) async throws -> [SongDB] {
        let songID = SongAlbumDB.CodingKeys.songID.rawValue
        let albumID = SongAlbumDB.CodingKeys.albumID.rawValue
        let songs: [SongDB] = try await songs
            .innerJoinEq(
                table: .songAlbum,
                joinedColumn: songID,
                equalColumn: albumID,
                equalValue: Int(album)
            )
            .execute()
            .value
        
        return songs
    }
    
    func tags(for song: Int8) async throws -> [TagDB] {
        let songID = SongTagDB.CodingKeys.songID.rawValue
        let tagID = SongTagDB.CodingKeys.tagID.rawValue
        let tags: [TagDB] = try await tags
            .innerJoinEq(
                table: .songTag,
                joinedColumn: tagID,
                equalColumn: songID,
                equalValue: Int(song)
            )
            .execute()
            .value
        
        return tags
    }
}

fileprivate extension PostgrestQueryBuilder {
    func innerJoin(table: DatabaseTables, column: String) async throws -> PostgrestFilterBuilder {
        self.select("*, \(table.rawValue)!inner(\(column))")
    }
    
    func innerJoinEq(
        table: DatabaseTables,
        joinedColumn: String,
        equalColumn: String,
        equalValue: URLQueryRepresentable
    ) async throws -> PostgrestFilterBuilder {
        try await self
            .innerJoin(table: table, column: joinedColumn)
            .eq("\(table.rawValue).\(equalColumn)", value: equalValue)
    }
}
