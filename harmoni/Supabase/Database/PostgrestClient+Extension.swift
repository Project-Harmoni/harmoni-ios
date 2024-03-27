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
        let user: UserDB = try await users
            .select()
            .eq(UserDB.CodingKeys.id.rawValue, value: id)
            .single()
            .execute()
            .value
        return user
    }
    
    func listener(with id: UUID) async throws -> ListenerDB? {
        let listener: ListenerDB = try await listeners
            .select()
            .eq(ListenerDB.CodingKeys.id.rawValue, value: id)
            .single()
            .execute()
            .value
        return listener
    }
    
    func artist(with id: UUID) async throws -> ArtistDB? {
        let artist: ArtistDB = try await artists
            .select()
            .eq(ArtistDB.CodingKeys.id.rawValue, value: id)
            .single()
            .execute()
            .value
        return artist
    }
    
    func tagCategory(with category: TagCategory) async throws -> TagCategoryDB? {
        let tagCategory: TagCategoryDB = try await tagCategories
            .select()
            .eq(TagCategoryDB.CodingKeys.name.rawValue, value: category.rawValue)
            .single()
            .execute()
            .value
        return tagCategory
    }
}
