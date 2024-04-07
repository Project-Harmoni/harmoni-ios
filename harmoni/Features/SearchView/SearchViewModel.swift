//
//  SearchViewModel.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/6/24.
//

import Foundation

class SearchViewModel: ObservableObject {
    @MainActor @Published var latestSongs: [Song] = []
    @Published var searchString: String = ""
    private let database: DBServiceProviding = DBService()
    
    @MainActor
    func getLatestSongs(force: Bool = false) async {
        do {
            guard latestSongs.isEmpty || force else { return }
            let songs: [SongDB] = try await database.getLatestSongs()
            var latest: [Song] = []
            for song in songs {
                guard let artistName = await getArtistName(for: song) else { continue }
                latest.append(.init(details: song, artistName: artistName))
            }
            latestSongs = latest
        } catch {
            dump(error)
        }
    }
    
    @MainActor
    private func getArtistName(for song: SongDB) async -> String? {
        guard let artistUUID = UUID(uuidString: song.artistID) else { return nil }
        do {
            let artist = try await database.getArtist(with: artistUUID)
            return artist?.name
        } catch {
            dump(error)
            return nil
        }
    }
}
