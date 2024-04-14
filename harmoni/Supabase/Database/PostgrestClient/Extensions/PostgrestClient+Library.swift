//
//  PostgrestClient+Library.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/13/24.
//

import Foundation
import Supabase

extension PostgrestClient {
    /// Get all songs for user's library
    func getLibrary(for user: String) async throws -> [Song] {
        let songID = SongDB.CodingKeys.id.rawValue
        let listenerID = UserDB.CodingKeys.id.rawValue
        let songs: [SongDB] = try await songs
            .innerJoinEq(
                table: .listenerSongLibrary,
                joinedColumn: songID,
                equalColumn: listenerID,
                equalValue: user
            )
            .execute()
            .value
        
        var library: [Song] = []
        for song in songs {
            if let artistName = try await artistNameForSong(song) {
                let albumID = try await albumIDForSong(song)
                library.append(
                    .init(
                        details: song,
                        artistName: artistName,
                        albumID: albumID
                    )
                )
            }
        }
        return library
    }
    
    /// Add song to library
    func addSongToLibrary(_ song: SongDB) async throws {
        try await Supabase.shared.client.database
            .listenerSongLibrary
            .upsert(song)
            .execute()
    }
    
    /// Add album to library
    func addAlbumToLibrary(_ album: AlbumDB) async throws {
        guard let id = album.id else { return }
        let songs: [SongDB] = try await songsOnAlbum(with: id)
        for song in songs {
            try await addSongToLibrary(song)
        }
    }
    
    /// Remove song from library
    func removeSongFromLibrary(_ song: SongDB) async throws {
        guard let id = song.id else { return }
        try await Supabase.shared.client.database
            .listenerSongLibrary
            .delete()
            .eq(SongDB.CodingKeys.id.rawValue, value: Int(id))
            .execute()
            .value
    }
    
    // Remove album from library
    func removeAlbumFromLibrary(_ album: AlbumDB) async throws {
        guard let id = album.id else { return }
        let songs: [SongDB] = try await songsOnAlbum(with: id)
        for song in songs {
            try await removeSongFromLibrary(song)
        }
    }
}
