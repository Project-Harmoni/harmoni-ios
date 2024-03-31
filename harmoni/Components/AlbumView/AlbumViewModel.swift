//
//  AlbumViewModel.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/31/24.
//

import Foundation

class AlbumViewModel: ObservableObject {
    let database: DBServiceProviding = DBService()
    let album: AlbumDB
    @MainActor @Published var songs: [SongDB] = []
    @MainActor @Published var selectedSongs: Set<SongDB.ID> = []
    @MainActor @Published var isPresentingEdit: Bool = false
    @MainActor @Published var isPresentingViewTags: Bool = false
    @MainActor @Published var isLoading: Bool = false
    @MainActor @Published var isError: Bool = false
    var allTagsViewModel: AllTagsViewModel
    
    init(album: AlbumDB) {
        self.album = album
        self.allTagsViewModel = AllTagsViewModel(
            albumID: album.id,
            isReadOnly: true
        )
    }
    
    @MainActor
    func getAlbum() async {
        guard songs.isEmpty else { return }
        do {
            guard let albumID = album.id else { return isError.toggle() }
            isLoading.toggle()
            songs = try await database.songsOnAlbum(with: albumID)
                .sorted(by: { $0.ordinal < $1.ordinal })
            isLoading.toggle()
        } catch {
            dump(error)
            isError.toggle()
            isLoading.toggle()
        }
    }
    
    var albumTitle: String? {
        album.name
    }
    
    var yearReleased: String? {
        album.yearReleased
    }
    
    var totalTracks: Int {
        album.totalTracks
    }
    
    var totalTracksLabel: String {
        plural(totalTracks, "song")
    }
    
    var duration: String? {
        guard let albumDuration = album.duration else { return nil }
        let seconds = modf(albumDuration).0
        let milliseconds = modf(albumDuration).1
        let duration = Duration.seconds(seconds) + Duration.milliseconds(milliseconds)
        return duration.formatted(.units(width: .wide))
    }
    
    var totalTracksDurationLabel: String? {
        [totalTracksLabel, duration]
            .compactMap { $0 }
            .joined(separator: ", ")
    }
    
    var recordLabel: String? {
        album.recordLabel
    }
    
    var tags: [Tag] {
        allTagsViewModel.tags
    }
}
