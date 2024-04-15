//
//  PostgrestClient+Common.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/13/24.
//

import Foundation
import Supabase

// TODO: - Clean-up

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
    
    func artistNameForSong(_ song: SongDB) async throws -> String? {
        guard let artistUUID = UUID(uuidString: song.artistID) else { return nil }
        return try await artist(with: artistUUID)?.name
    }
    
    func does(artist: UUID, own album: Int8) async throws -> Bool {
        let albums = try await albumsByArtist(with: artist)
        return albums.contains(where: { $0.id == album })
    }
    
    func tagCategory(with category: TagCategory) async throws -> TagCategoryDB? {
        let tagCategories: [TagCategoryDB] = try await tagCategories
            .select()
            .eq(TagCategoryDB.CodingKeys.name.rawValue, value: category.rawValue)
            .execute()
            .value
        return tagCategories.first
    }
    
    func tagCategories() async throws -> [TagCategoryDB]? {
        let tagCategories: [TagCategoryDB] = try await tagCategories
            .select()
            .execute()
            .value
        return tagCategories
    }
    
    func albumsByArtist(with id: UUID) async throws -> [AlbumDB] {
        let albums: [AlbumDB] = try await albums
            .select()
            .eq(AlbumDB.CodingKeys.artistID.rawValue, value: id)
            .execute()
            .value
        return albums
    }
    
    func albumIDForSong(_ song: SongDB) async throws -> Int8? {
        guard let id = song.id else { return nil }
        let albums: [SongAlbumDB] = try await songAlbums
            .select()
            .eq(SongAlbumDB.CodingKeys.songID.rawValue, value: Int(id))
            .execute()
            .value
        
        return albums.first?.albumID
    }
    
    func albumForSong(_ song: SongDB) async throws -> AlbumDB? {
        guard let albumID = try await albumIDForSong(song) else { return nil }
        let albums: [AlbumDB] = try await albums
            .select()
            .eq(AlbumDB.CodingKeys.id.rawValue, value: Int(albumID))
            .execute()
            .value
        
        return albums.first
    }
    
    func songsOnAlbum(with id: Int8) async throws -> [SongDB] {
        let songID = SongAlbumDB.CodingKeys.songID.rawValue
        let albumID = SongAlbumDB.CodingKeys.albumID.rawValue
        let songs: [SongDB] = try await songs
            .innerJoinEq(
                table: .songAlbum,
                joinedColumn: songID,
                equalColumn: albumID,
                equalValue: Int(id)
            )
            .execute()
            .value
        
        return songs
    }
    
    func getLatestSongs() async throws -> [Song] {
        let songs: [SongDB] = try await self.songs
            .select()
            .order(SongDB.CodingKeys.createdAt.rawValue, ascending: false)
            .limit(30)
            .execute()
            .value
        
        var latest: [Song] = []
        for song in songs {
            guard let artistName = try await artistNameForSong(song) else { continue }
            latest.append(.init(details: song, artistName: artistName))
        }
        return latest
    }
    
    func deleteSong(with id: Int8) async throws {
        _ = try await songs
            .delete()
            .eq(SongDB.CodingKeys.id.rawValue, value: Int(id))
            .execute()
    }
    
    func deleteAlbums(with ids: [Int8], in storage: StorageProviding) async throws {
        for id in ids {
            try await deleteAlbum(with: id, in: storage)
        }
    }
    
    func deleteAlbum(with id: Int8, in storage: StorageProviding) async throws {
        let albums: [AlbumDB] = try await albums
            .select()
            .eq(AlbumDB.CodingKeys.id.rawValue, value: Int(id))
            .execute()
            .value
        
        for album in albums {
            guard let albumID = album.id else { continue }
            let songs = try await songsOnAlbum(with: albumID)
            for song in songs {
                guard let songID = song.id else { continue }
                // Delete cover art from storage
                if let coverImagePath = song.coverImagePath, let url = URL(string: coverImagePath) {
                    try await storage.deleteImage(name: url.lastPathComponent)
                }
                // Delete track from storage
                if let filePath = song.filePath, let url = URL(string: filePath) {
                    try await storage.deleteSong(name: url.lastPathComponent)
                }
                // Delete song on album
                try await deleteSong(with: songID)
            }
            
            // Delete album
            _ = try await self.albums
                .delete()
                .eq(AlbumDB.CodingKeys.id.rawValue, value: Int(id))
                .execute()
                .value
        }
    }
    
    func tagsOnAlbum(with id: Int8) async throws -> [Tag] {
        let songs = try await songsOnAlbum(with: id)
        let tagCategories = try await tagCategories()
        var tagSet: Set<Tag> = []
        // Since all songs have the same tags applied, get first song
        // TODO: - Allow applying different tags to individual songs
        guard let song = songs.first else { return [] }
        guard let id = song.id else { return [] }
        for tag in try await self.tagsOnSong(with: id, and: tagCategories) {
            tagSet.insert(tag)
        }
        return Array(tagSet)
    }
    
    private func tagsOnSong(with id: Int8, and tagCategories: [TagCategoryDB]?) async throws -> [Tag] {
        let songID = SongTagDB.CodingKeys.songID.rawValue
        let tagID = SongTagDB.CodingKeys.tagID.rawValue
        let tagsDB: [TagDB] = try await tags
            .innerJoinEq(
                table: .songTag,
                joinedColumn: tagID,
                equalColumn: songID,
                equalValue: Int(id)
            )
            .execute()
            .value
        
        var tagSet: Set<Tag> = []
        tagsDB.forEach { tagDB in
            if let tagCategory = tagCategories?.first(where: { $0.id == tagDB.categoryID }),
               let category = tagCategory.toCategory() {
                tagSet.insert(Tag(serverID: tagDB.id, name: tagDB.name, category: category))
            }
        }
        
        return Array(tagSet)
    }
    
    /// Get tags contained in query
    private func tags(in query: [String]) async throws -> [TagDB] {
        guard query.isNotEmpty else { return [] }
        var tagsFromQuery: [TagDB] = []
        for name in query {
            if name.trimmingCharacters(in: .whitespacesAndNewlines).isNotEmpty {
                let tagsFromDB: [TagDB] = try await self.tags
                    .select()
                    .ilike(TagDB.CodingKeys.name.rawValue, value: "*\(name)*")
                    .execute()
                    .value
                
                for tag in tagsFromDB {
                    tagsFromQuery.append(tag)
                }
            }
        }
        return tagsFromQuery
    }
    
    /// Get tags contained in query
    private func tags(in query: [String], with category: TagCategory) async throws -> [TagDB] {
        guard query.isNotEmpty else { return [] }
        guard let categoryID = try await tagCategory(with: category)?.id else { return [] }
        var tagsFromQuery: [TagDB] = []
        for name in query {
            if name.trimmingCharacters(in: .whitespacesAndNewlines).isNotEmpty {
                let tagsFromDB: [TagDB] = try await self.tags
                    .select()
                    .ilike(TagDB.CodingKeys.name.rawValue, value: "*\(name)*")
                    .eq(TagDB.CodingKeys.categoryID.rawValue, value: Int(categoryID))
                    .execute()
                    .value
                
                for tag in tagsFromDB {
                    tagsFromQuery.append(tag)
                }
            }
        }
        return tagsFromQuery
    }
    
    /// Get tags in category
    func tags(in category: TagCategory) async throws -> [TagDB] {
        let categories = try await tagCategories()
        let categoryID = categories?
            .filter({ $0.name == category.rawValue })
            .first?.id
        guard let categoryID else { return [] }
        return try await tags
            .select()
            .eq(TagDB.CodingKeys.categoryID.rawValue, value: Int(categoryID))
            .execute()
            .value
    }
    
    /// Get 5 songs with tag(s)
    func songsWithTags(_ tags: [String], in category: TagCategory? = nil) async throws -> [Song] {
        var matchingTags: [TagDB] = []
        if let category {
            matchingTags = try await self.tags(in: tags, with: category)
        } else {
            matchingTags = try await self.tags(in: tags)
        }
        let matchingTagIDs = matchingTags
            .compactMap { $0.id }
            .compactMap { Int($0) }
        let songID = SongTagDB.CodingKeys.songID.rawValue
        let tagID = SongTagDB.CodingKeys.tagID.rawValue
        let taggedSongs: [SongDB] = try await songs
            .innerJoinIn(
                table: .songTag,
                joinedColumn: songID,
                inColumn: tagID,
                inValue: matchingTagIDs
            )
            .limit(5)
            .execute()
            .value
        
        var songsWithTags: [Song] = []
        for song in taggedSongs {
            if let artist = try await artistNameForSong(song) {
                songsWithTags.append(.init(details: song, artistName: artist))
            }
        }
        return songsWithTags
    }
    
    /// General search by query
    func search(with query: SearchQuery) async throws -> SearchResults {
        let songsFromSearch: [SongDB] = try await songs
            .select()
            .ilike(SongDB.CodingKeys.name.rawValue, value: query.value)
            .limit(5)
            .execute()
            .value
        
        var songs: [Song] = []
        for song in songsFromSearch {
            if let artist = try await artistNameForSong(song) {
                songs.append(.init(details: song, artistName: artist))
            }
        }
        
        let songsWithTags: [Song] = try await self.songsWithTags(query.tagValue)
        
        let albums: [AlbumDB] = try await albums
            .select()
            .ilike(AlbumDB.CodingKeys.name.rawValue, value: query.value)
            .limit(5)
            .execute()
            .value
        
        let artists: [ArtistDB] = try await artists
            .select()
            .ilike(ArtistDB.CodingKeys.name.rawValue, value: query.value)
            .limit(5)
            .execute()
            .value
        
        return .init(
            songs: songs,
            songsWithTags: songsWithTags,
            albums: albums,
            artists: artists
        )
    }
    
    /// Advanced search by query
    func advancedSearch(with query: SearchQuery) async throws -> SearchResults {
        var songs: [Song] = []
        if query.isAdvancedSongTitleAvailable {
            let songsFromSearch: [SongDB] = try await self.songs
                .select()
                .ilike(SongDB.CodingKeys.name.rawValue, value: query.advancedSongTitleValue)
                .limit(5)
                .execute()
                .value
            
            for song in songsFromSearch {
                if let artist = try await artistNameForSong(song) {
                    songs.append(.init(details: song, artistName: artist))
                }
            }
        }
        
        var genreSongs: [Song] = []
        if query.genreTags.isNotEmpty {
            genreSongs = try await self.songsWithTags(query.genreTagsQuery, in: .genres)
        }
        var moodSongs: [Song] = []
        if query.moodTags.isNotEmpty {
            moodSongs = try await self.songsWithTags(query.moodTagsQuery, in: .moods)
        }
        var instrumentsSongs: [Song] = []
        if query.instrumentsTags.isNotEmpty {
            instrumentsSongs = try await self.songsWithTags(query.instrumentsTagsQuery, in: .instruments)
        }
        var miscSongs: [Song] = []
        if query.miscTags.isNotEmpty {
            miscSongs = try await self.songsWithTags(query.miscTagsQuery, in: .miscellaneous)
        }
        
        var albums: [AlbumDB] = []
        if query.isAdvancedAlbumTitleAvailable {
            albums = try await self.albums
                .select()
                .ilike(AlbumDB.CodingKeys.name.rawValue, value: query.advancedAlbumTitleValue)
                .limit(5)
                .execute()
                .value
        }
        var artists: [ArtistDB] = []
        if query.isAdvancedArtistNameAvailable {
            artists = try await self.artists
                .select()
                .ilike(ArtistDB.CodingKeys.name.rawValue, value: query.advancedArtistNameValue)
                .limit(5)
                .execute()
                .value
        }
        
        return .init(
            songs: songs,
            genreTaggedSongs: genreSongs,
            moodTaggedSongs: moodSongs,
            instrumentTaggedSongs: instrumentsSongs,
            miscTaggedSongs: miscSongs,
            albums: albums,
            artists: artists
        )
    }
}
