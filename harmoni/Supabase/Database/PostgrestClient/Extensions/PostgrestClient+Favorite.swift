//
//  PostgrestClient+Favorite.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/19/24.
//

import Foundation
import Supabase

extension PostgrestClient {
    func likeSong(for user: String, song: Int) async throws {
        try await Supabase.shared.client.database
            .listenerSongLikes
            .insert(ListenerSongLikeDB(listenerID: user, songID: song))
            .execute()
    }
    
    func unlikeSong(for user: String, song: Int) async throws {
        try await Supabase.shared.client.database
            .listenerSongLikes
            .delete()
            .eq(ListenerSongLikeDB.CodingKeys.songID.rawValue, value: Int(song))
            .execute()
            .value
    }
    
    func likeCountFor(song: Int) async throws -> String {
        let likes: [ListenerSongLikeDB] = try await listenerSongLikes
            .select()
            .eq(ListenerSongLikeDB.CodingKeys.songID.rawValue, value: Int(song))
            .execute()
            .value
        return String(likes.count)
    }
    
    func likedSongsFor(user: String) async throws -> [Song] {
        let songID = ListenerSongLikeDB.CodingKeys.songID.rawValue
        let listenerID = ListenerSongLikeDB.CodingKeys.listenerID.rawValue
        let songs: [SongDB] = try await songs
            .innerJoinEq(
                table: .listenerSongLikes,
                joinedColumn: songID,
                equalColumn: listenerID,
                equalValue: user
            )
            .limit(60)
            .execute()
            .value
        
        var librarySongs: [Song] = []
        for song in songs {
            if let artistName = try await artistNameForSong(song),
               let album = try await albumForSong(song) {
                librarySongs.append(
                    .init(
                        details: song,
                        artistName: artistName,
                        album: album
                    )
                )
            }
        }
        
        return librarySongs
    }
    
    func isSongLiked(_ song: SongDB) async throws -> Bool {
        guard let id = song.id else { return false }
        let likes: [ListenerSongLikeDB] = try await listenerSongLikes
            .select()
            .eq(ListenerSongLikeDB.CodingKeys.songID.rawValue, value: Int(id))
            .execute()
            .value
        return likes.isNotEmpty
    }
}
