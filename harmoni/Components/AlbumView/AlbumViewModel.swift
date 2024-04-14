//
//  AlbumViewModel.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/31/24.
//

import Foundation

class AlbumViewModel: ObservableObject {
    let database: DBServiceProviding = DBService()
    let userProvider: UserProviding = UserProvider()
    let storage: StorageProviding = StorageService()
    let album: AlbumDB
    @MainActor @Published var isOwner: Bool = false
    @MainActor @Published var songs: [Song] = []
    @MainActor @Published var selectedSongs: Set<Song.ID> = []
    @MainActor @Published var isPresentingDeleteConfirm: Bool = false
    @MainActor @Published var isPresentingEdit: Bool = false
    @MainActor @Published var isPresentingViewTags: Bool = false
    @MainActor @Published var isLoading: Bool = true
    @MainActor @Published var isDeleting: Bool = false
    @MainActor @Published var isDeleted: Bool = false
    @MainActor @Published var isError: Bool = false
    var allTagsViewModel: AllTagsViewModel
    var onDelete: (() -> Void)?
    
    init(album: AlbumDB, onDelete: (() -> Void)? = nil) {
        self.album = album
        self.onDelete = onDelete
        self.allTagsViewModel = AllTagsViewModel(
            albumID: album.id,
            isReadOnly: true
        )
        self.checkIfOwner()
    }
    
    private func checkIfOwner() {
        Task { @MainActor [weak self] in
            guard let self else { return }
            guard let id = album.id else { return }
            guard let artistID = await userProvider.currentUserID else { return }
            self.isOwner = try await database.does(artist: artistID, own: id)
        }
    }
    
    @MainActor
    func getAlbum() async {
        guard songs.isEmpty else { return }
        do {
            guard let albumID = album.id else { return isError.toggle() }
            guard let artistName = await artistName else { return isError.toggle() }
            isLoading = true
            let songsOnAlbum = try await database.songsOnAlbum(with: albumID)
                .sorted(by: { $0.ordinal < $1.ordinal })
            songs = songsOnAlbum.map {
                .init(details: $0, artistName: artistName)
            }
            isLoading.toggle()
        } catch {
            dump(error)
            isError.toggle()
            isLoading = false
        }
    }
    
    var artistName: String? {
        get async {
            guard let artistUUID = UUID(uuidString: album.artistID) else { return nil }
            do {
                let artist = try await database.getArtist(with: artistUUID)
                return artist?.name
            } catch {
                dump(error)
                return nil
            }
        }
    }
    
    @MainActor
    func deleteAlbum() async {
        do {
            isDeleting.toggle()
            try await database.deleteAlbum(with: album.id, in: storage)
            onDelete?()
            isDeleting.toggle()
            isDeleted.toggle()
        } catch {
            dump(error)
            isError.toggle()
            isDeleting.toggle()
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
