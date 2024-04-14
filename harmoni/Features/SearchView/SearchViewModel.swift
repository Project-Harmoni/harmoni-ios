//
//  SearchViewModel.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/6/24.
//

import Combine
import Foundation

class SearchViewModel: ObservableObject {
    @Published var filterViewModel = SearchFilterViewModel()
    @MainActor @Published var latestSongs: [Song] = []
    @MainActor @Published var songsWithTags: [Song] = []
    @MainActor @Published var genreSongsWithTags: [Song] = []
    @MainActor @Published var moodSongsWithTags: [Song] = []
    @MainActor @Published var instrumentsSongsWithTags: [Song] = []
    @MainActor @Published var miscSongsWithTags: [Song] = []
    @MainActor @Published var songsThatMatchQuery: [Song] = []
    @MainActor @Published var albumsThatMatchQuery: [AlbumDB] = []
    @MainActor @Published var artistsThatMatchQuery: [ArtistDB] = []
    @MainActor @Published var advancedSearchSongsThatMatchQuery: [Song] = []
    @MainActor @Published var advancedSearchAlbumsThatMatchQuery: [AlbumDB] = []
    @MainActor @Published var advancedSearchArtistsThatMatchQuery: [ArtistDB] = []
    @Published var isPresentingFilters: Bool = false
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
                    if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        self.clear()
                    } else {
                        await self.search(SearchQuery(query: query))
                    }
                }
            }
            .store(in: &cancellables)
        
        filterViewModel.objectWillChange
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                Task { @MainActor in
                    await self.advancedSearch(SearchQuery(filters: self.filterViewModel))
                }
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest4(
            filterViewModel.genreTagsViewModel.$tags,
            filterViewModel.moodTagsViewModel.$tags,
            filterViewModel.instrumentsTagsViewModel.$tags,
            filterViewModel.miscTagsViewModel.$tags
        )
        .debounce(for: 0.5, scheduler: DispatchQueue.main)
        .receive(on: DispatchQueue.main)
        .sink { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                await self.advancedSearch(SearchQuery(filters: self.filterViewModel))
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
    func search(_ query: SearchQuery) async {
        do {
            let searchResults = try await database.search(with: query)
            songsThatMatchQuery = searchResults.songs
            songsWithTags = searchResults.songsWithTags
            albumsThatMatchQuery = searchResults.albums
            artistsThatMatchQuery = searchResults.artists
        } catch {
            dump(error)
        }
    }
    
    @MainActor
    func advancedSearch(_ query: SearchQuery) async {
        do {
            let searchResults = try await database.advancedSearch(with: query)
            genreSongsWithTags = searchResults.genreTaggedSongs
            moodSongsWithTags = searchResults.moodTaggedSongs
            instrumentsSongsWithTags = searchResults.instrumentTaggedSongs
            miscSongsWithTags = searchResults.miscTaggedSongs
            advancedSearchSongsThatMatchQuery = searchResults.songs
            advancedSearchAlbumsThatMatchQuery = searchResults.albums
            advancedSearchArtistsThatMatchQuery = searchResults.artists
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
