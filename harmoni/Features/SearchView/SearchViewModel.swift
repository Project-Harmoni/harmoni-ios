//
//  SearchViewModel.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/6/24.
//

import Combine
import Foundation

class SearchViewModel: ObservableObject {
    @MainActor @Published var latestSongs: [Song] = []
    @MainActor @Published var songsWithTags: [Song] = []
    @MainActor @Published var songsThatMatchQuery: [Song] = []
    @MainActor @Published var albumsThatMatchQuery: [AlbumDB] = []
    @MainActor @Published var artistsThatMatchQuery: [ArtistDB] = []
    @Published var isShowingInfoPopover: Bool = false
    @Published var searchString: String = ""
    private let database: DBServiceProviding = DBService()
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        $searchString
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] query in
                guard let self else { return }
                Task { @MainActor in
                    if query.isEmpty {
                        self.clear()
                    } else {
                        await self.search(query)
                    }
                }
            }
            .store(in: &cancellables)
        
    }
    
    @MainActor
    func getLatestSongs(force: Bool = false) async {
        do {
            guard latestSongs.isEmpty || force else { return }
            latestSongs = try await database.getLatestSongs()
        } catch {
            dump(error)
        }
    }
    
    @MainActor
    func search(_ query: String) async {
        let searchQuery = SearchQuery(query: query)
        do {
            let searchResults = try await database.search(with: searchQuery)
            songsThatMatchQuery = searchResults.songs
            songsWithTags = searchResults.songsWithTags
            albumsThatMatchQuery = searchResults.albums
            artistsThatMatchQuery = searchResults.artists
        } catch {
            dump(error)
        }
    }
    
    @MainActor
    private func clear() {
        songsThatMatchQuery = []
        songsWithTags = []
        albumsThatMatchQuery = []
        artistsThatMatchQuery = []
    }
}
