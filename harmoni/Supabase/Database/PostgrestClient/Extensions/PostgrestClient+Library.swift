//
//  PostgrestClient+Library.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/13/24.
//

import Foundation
import Supabase

struct LibraryItem: Identifiable {
    let id = UUID()
    var songs: [Song]
    var album: AlbumDB?
    var artistName: String?
    var addedOn: String?
    
    var date: Date? {
        guard let addedOn else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZZZZZ"
        return formatter.date(from: addedOn)
    }
}

private struct LibraryMedia {
    var song: Song
    var addedOn: String?
}

extension PostgrestClient {
    /// Get 60 most recent songs added to user's library
    func getLibrary(for user: String) async throws -> [LibraryItem] {
        let songID = ListenerSongLibraryDB.CodingKeys.songID.rawValue
        let listenerID = ListenerSongLibraryDB.CodingKeys.listenerID.rawValue
        let songs: [SongDB] = try await songs
            .innerJoinEq(
                table: .listenerSongLibrary,
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
        
        var library: [LibraryMedia] = []
        for song in librarySongs {
            if let id = song.details.id {
                let listenerLibrary: [ListenerSongLibraryDB] = try await listenerSongLibrary
                    .select()
                    .eq(ListenerSongLibraryDB.CodingKeys.songID.rawValue, value: Int(id))
                    .execute()
                    .value
                
                guard let libraryDB = listenerLibrary.first else { continue }
                library.append(.init(song: song, addedOn: libraryDB.addedOn))
            }
        }
        
        let songsByAlbum = Dictionary(grouping: library, by: { $0.song.album?.id })
        return songsByAlbum.values.map {
            LibraryItem(
                songs: $0.map { $0.song },
                album: $0.first?.song.album,
                artistName: $0.first?.song.artistName,
                addedOn: $0.first?.addedOn
            )
        }
    }
    
    /// Get artists added to user's library
    func getLibraryArtists(for user: String) async throws -> [ArtistDB] {
        let songID = ListenerSongLibraryDB.CodingKeys.songID.rawValue
        let listenerID = ListenerSongLibraryDB.CodingKeys.listenerID.rawValue
        let songs: [SongDB] = try await songs
            .innerJoinEq(
                table: .listenerSongLibrary,
                joinedColumn: songID,
                equalColumn: listenerID,
                equalValue: user
            )
            .execute()
            .value
        
        var artists: Set<ArtistDB> = []
        for song in songs {
            if let artistID = UUID(uuidString: song.artistID), 
               let artist = try await artist(with: artistID) {
                artists.insert(artist)
            }
        }
        
        return Array(artists)
    }
    
    // Is song in library?
    func isSongInLibrary(_ song: SongDB, _ user: String) async throws -> Bool {
        guard let id = song.id else { return false }
        let library: [ListenerSongLibraryDB] = try await listenerSongLibrary
            .select()
            .eq(ListenerSongLibraryDB.CodingKeys.songID.rawValue, value: Int(id))
            .eq(ListenerSongLibraryDB.CodingKeys.listenerID.rawValue, value: user)
            .execute()
            .value
        return library.isNotEmpty
    }
    
    // Is album in library?
    func isAlbumInLibrary(_ album: AlbumDB, _ user: String) async throws -> Bool {
        guard let id = album.id else { return false }
        let songs = try await songsOnAlbum(with: id)
        for song in songs {
            if try await isSongInLibrary(song, user) == false {
               return false
            }
        }
        return true
    }
    
    /// Add song to library
    func addSongToLibrary(for user: String, song: SongDB) async throws {
        try await Supabase.shared.client.database
            .listenerSongLibrary
            .insert(ListenerSongLibraryDB(listenerID: user, songID: song.id))
            .execute()
    }
    
    /// Add album to library
    func addAlbumToLibrary(for user: String, album: AlbumDB) async throws {
        guard let id = album.id else { return }
        let songs: [SongDB] = try await songsOnAlbum(with: id)
        for song in songs {
            try await addSongToLibrary(for: user, song: song)
        }
    }
    
    /// Remove song from library
    func removeSongFromLibrary(_ song: SongDB, _ user: String) async throws {
        guard let id = song.id else { return }
        try await Supabase.shared.client.database
            .listenerSongLibrary
            .delete()
            .eq(SongDB.CodingKeys.id.rawValue, value: Int(id))
            .eq(ListenerSongLibraryDB.CodingKeys.listenerID.rawValue, value: user)
            .execute()
            .value
    }
    
    // Remove album from library
    func removeAlbumFromLibrary(_ album: AlbumDB, _ user: String) async throws {
        guard let id = album.id else { return }
        let songs: [SongDB] = try await songsOnAlbum(with: id)
        for song in songs {
            try await removeSongFromLibrary(song, user)
        }
    }
}
