//
//  SearchViewModel.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/6/24.
//

import Combine
import Foundation

struct SearchResults {
    var songs: [Song]
    var albums: [AlbumDB]
    var artists: [ArtistDB]
    var tags: [TagDB]
}

class SearchViewModel: ObservableObject {
    @MainActor @Published var latestSongs: [Song] = []
    @Published var isShowingInfoPopover: Bool = false
    @Published var searchString: String = ""
    private let database: DBServiceProviding = DBService()
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        $searchString
            .debounce(for: 2, scheduler: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] query in
                guard let self else { return }
                Task {
                    await self.search(query)
                }
            }
            .store(in: &cancellables)
        
    }
    
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
    
    @MainActor
    func search(_ query: String) async {
        
    }
}
