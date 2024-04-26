//
//  PostgrestClient+RecentlyPlayed.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/25/24.
//

import Foundation
import Supabase

extension PostgrestClient {
    func getRecentlyPlayedFor(user: String) async throws -> [Song] {
        let songID = ListenerSongStreamDB.CodingKeys.songID.rawValue
        let listenerID = ListenerSongStreamDB.CodingKeys.listenerID.rawValue
        let songs: [SongDB] = try await songs
            .innerJoinEq(
                table: .listenerSongStream,
                joinedColumn: songID,
                equalColumn: listenerID,
                equalValue: user
            )
            .limit(30)
            .execute()
            .value
        
        var recentlyPlayed: [Song] = []
        for song in songs {
            if let artistName = try await artistNameForSong(song),
               let album = try await albumForSong(song) {
                recentlyPlayed.append(
                    .init(
                        details: song,
                        artistName: artistName,
                        album: album
                    )
                )
            }
        }
        
        return recentlyPlayed
    }
}
