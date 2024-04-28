//
//  LibraryAlbumViewModel.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/20/24.
//

import Foundation

class LibraryAlbumViewModel: ObservableObject {
    @MainActor @Published var isDisplayingCopyrightInfringementRequest: Bool = false
    @MainActor @Published var isDisplayingBlacklistRequest: Bool = false
    @MainActor @Published var isPresentingViewTags: Bool = false
    @MainActor @Published var isPresentingRemoveConfirm: Bool = false
    @MainActor @Published var isRemoving: Bool = false
    @MainActor @Published var isRemoved: Bool = false
    private let database: DBServiceProviding = DBService()
    let item: LibraryItem
    var allTagsViewModel: AllTagsViewModel?
    
    init(item: LibraryItem) {
        self.item = item
        self.allTagsViewModel = AllTagsViewModel(
            albumID: albumID,
            isReadOnly: true
        )
    }
    
    var albumID: Int? {
        guard let firstSong = item.songs.first else { return nil }
        return firstSong.album?.id
    }
    
    var albumCoverPath: String? {
        guard let firstSong = item.songs.first else { return nil }
        return firstSong.details.coverImagePath
    }
    
    var albumTitle: String? {
        guard let firstSong = item.songs.first else { return nil }
        return firstSong.details.albumName
    }
    
    var artistName: String? {
        guard let firstSong = item.songs.first else { return nil }
        return firstSong.artistName
    }
    
    
    var yearReleased: String? {
        item.album?.yearReleased
    }
    
    var totalTracks: Int {
        item.songs.count
    }
    
    var totalTracksLabel: String {
        return plural(totalTracks, "song")
    }

    var totalTracksDurationLabel: String {
        totalTracksLabel
    }
    
    var recordLabel: String? {
        item.album?.recordLabel
    }
    
    @MainActor
    func removeAlbum() async {
        do {
            guard let album = item.album else { return }
            try await database.removeAlbumFromLibrary(album)
        } catch {
            dump(error)
        }
    }
}
