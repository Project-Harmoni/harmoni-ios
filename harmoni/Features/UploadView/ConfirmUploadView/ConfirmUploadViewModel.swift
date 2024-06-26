//
//  ConfirmUploadViewModel.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/26/24.
//

import Kingfisher
import UIKit

enum UploadError: Error {
    case failedToInitiatePayout
}

class ConfirmUploadViewModel: ObservableObject {
    @MainActor @Published var isShowingCompletedToast: Bool = false
    @MainActor @Published var isSaving: Bool = false
    @MainActor @Published var isError: Bool = false
    private let database: DBServiceProviding
    private let rpc: RPCProviding
    private let edge: EdgeProviding
    private let storage: StorageProviding
    private let userProvider: UserProviding
    private var uploadedSongs: [SongDB] = []
    private var uploadedAlbum: AlbumDB?
    private var uploadedTags: [TagDB] = []
    var store: UploadStore?
    
    init(
        database: DBServiceProviding = DBService(),
        rpc: RPCProviding = RPCProvider(),
        edge: EdgeProviding = EdgeService(),
        storage: StorageProviding = StorageService(),
        userProvider: UserProviding = UserProvider()
    ) {
        self.database = database
        self.rpc = rpc
        self.edge = edge
        self.storage = storage
        self.userProvider = userProvider
    }
    
    func upload() {
        Task.detached { @MainActor [weak self] in
            guard let self else { return }
            do {
                self.isSaving.toggle()
                // Get current user's UUID
                guard let currentUserID = await self.userProvider.currentUserID else {
                    return self.isError.toggle()
                }
                // Upload cover art to storage
                guard let albumCoverPath = try await self.uploadCoverArt() else {
                    return self.isError.toggle()
                }
                
                // Update artist name in database, if needed
                try await self.updateArtistName(with: currentUserID)
                
                // Update album in database
                try await self.updateAlbum(for: currentUserID, with: albumCoverPath)
                
                // Upload tracks to storage and update database
                try await self.uploadTracks(for: currentUserID, with: albumCoverPath)
                
                // Update tags in database
                try await self.updateTags()
                
                // After tracks, album, and tags are uploaded, update association tables in database
                try await self.updateAssociationTables()
                
                // Check if payout needs to occur based on stream thresholds
                self.checkIfPayoutRequired()
                
                self.isSaving.toggle()
                self.isShowingCompletedToast.toggle()
                KingfisherManager.shared.cache.clearCache()
            } catch {
                dump(error)
                self.isSaving.toggle()
                self.isError.toggle()
            }
        }
    }
    
    /// Upload tracks in storage and update database
    @MainActor
    private func uploadTracks(for userID: UUID, with coverPath: String) async throws {
        guard let store else { return self.isError.toggle() }
        for track in store.tracks {
            // upload track to storage
            guard let filePath = try await self.upload(track: track, userID: userID.uuidString) else {
                return self.isError.toggle()
            }
            
            // update songs table
            let song = SongDB(
                track: track,
                albumName: store.albumTitle,
                artistID: userID,
                coverImagePath: coverPath,
                filePath: filePath,
                isExplicit: store.isExplicit
            )
            
            if let uploadedSong = try await self.updateSong(song) {
                self.uploadedSongs.append(uploadedSong)
            }
        }
    }
    
    private func upload(track: Track, userID: String) async throws -> String? {
        guard let store else { return nil }
        let url = track.url
        try await deleteTracksIfNeeded()
        guard let trackName = await nameForTrack(track, userID) else { return nil }
        // upload track to storage
        if !store.isEditing || isTrackFileChanged {
            #if !targetEnvironment(simulator)
                guard url.startAccessingSecurityScopedResource() else { return nil }
            #endif
            let trackData = try Data(contentsOf: track.url)
            let _ = try await self.uploadTrack(trackData, trackName)
            #if !targetEnvironment(simulator)
                url.stopAccessingSecurityScopedResource()
            #endif
        }
        // get public file url from storage
        let trackURL = try self.storage.getMusicURL(for: trackName)
        return trackURL.absoluteString
    }
    
    private func uploadCoverArt() async throws -> String? {
        if let albumCoverData {
            guard let jpegData = UIImage(data: albumCoverData)?
                .aspectFitToHeight()
                .jpegData(compressionQuality: 0.7)
            else {
                return nil
            }
            guard let albumCoverName = await self.albumCoverName else { return nil }
            // upload image to storage
            let _ = try await self.uploadCoverArt(data: jpegData, name: albumCoverName)
            // get public image url from storage
            let imageURL = try self.storage.getImageURL(for: albumCoverName)
            return imageURL.absoluteString
        } else {
            return nil
        }
    }
    
    /// Update tags for genres, moods, instruments, and miscellaneous
    @MainActor
    private func updateTags() async throws {
        guard let store else { return self.isError.toggle() }
        for tagViewModel in store.tagViewModels {
            if let category = try await database.getTagCategory(with: tagViewModel.category), let id = category.id {
                let tagNames = tagViewModel.tags.map { $0.name }
                for song in uploadedSongs {
                    if let songID = song.id  {
                        try await rpc.addManySongTags(
                            .init(
                                songID: songID,
                                tagNames: tagNames,
                                tagCategoryID: id
                            )
                        )
                    }
                }
            }
        }
    }
    
    /// Update artist table with name, if needed
    @MainActor
    private func updateArtistName(with id: UUID) async throws {
        guard let store else { return self.isError.toggle() }
        guard var artist = try await self.database.getArtist(with: id) else {
            return self.isError.toggle()
        }
        if let artistName = artist.name, artistName.isEmpty {
            artist.name = store.artistName
            isEditing 
            ? try await self.database.update(artist: artist)
            : try await self.database.upsert(artist: artist)
        }
    }
    
    /// Update album in database
    @MainActor
    private func updateAlbum(for userID: UUID, with coverPath: String) async throws {
        guard let store else { return self.isError.toggle() }
        let album = AlbumDB(
            id: isEditing ? store.albumToEdit?.id : nil,
            name: store.albumTitle,
            artistID: userID.uuidString,
            coverImagePath: coverPath,
            yearReleased: store.yearReleased,
            totalTracks: store.tracks.count,
            recordLabel: store.recordLabel,
            duration: await store.durationOfTracks,
            isExplicit: store.isExplicit
        )
        self.uploadedAlbum = isEditing
        ? try await self.database.update(album: album)
        : try await self.database.upsert(album: album)
    }
    
    /// Update song/album table in database
    private func updateSongAlbumAssociations() async throws {
        guard isTrackFileChanged || areTracksEmpty else { return }
        for uploadedSong in uploadedSongs {
            let songAlbummDB = SongAlbumDB(
                songID: uploadedSong.id,
                albumID: self.uploadedAlbum?.id
            )
            _ = try await self.database.upsert(songAlbum: songAlbummDB)
        }
    }
    
    /// After tracks, album, and tags are uploaded, update association tables in database
    private func updateAssociationTables() async throws {
        // Update song/album table in database
        try await self.updateSongAlbumAssociations()
    }
    
    /// Check if payout needs to occur based on stream thresholds
    private func checkIfPayoutRequired() {
        Task { [weak self] in
            guard let self else { return }
            guard let store else { return }
            for track in store.tracks {
                do {
                    if track.isPayoutRequired, let songID = track.serverID {
                        let response = try await self.edge.initiateSongPayout(request: .init(songID: String(songID)))
                        if response?.error != nil { throw UploadError.failedToInitiatePayout }
                    }
                } catch {
                    dump(error)
                }
            }
        }
    }
}

// MARK: - Editing Helpers

extension ConfirmUploadViewModel {
    private var isEditing: Bool {
        store?.isEditing ?? false
    }
    
    private var isTrackFileChanged: Bool {
        let tracksToDeleteServerIDs = store?.loadedTracks.compactMap { $0.serverID }
        let tracksServerIDs = store?.tracks.compactMap { $0.serverID }
        return tracksToDeleteServerIDs != tracksServerIDs
    }
    
    private var albumCoverData: Data? {
        store?.albumCoverData
    }
    
    private var albumCoverName: String? {
        get async {
            isEditing
            ? store?.albumToEdit?.coverImageStorageBucketName
            : await store?.albumCoverName
        }
    }
    
    private func nameForTrack(_ track: Track, _ userID: String) async -> String? {
        isTrackFileChanged || areTracksEmpty
        ? await store?.name(for: track)
        : "\(userID)/\(track.url.lastPathComponent)"
    }
    
    private func uploadCoverArt(data: Data, name: String) async throws -> String {
        isEditing
        ? try await self.storage.updateImage(data, name: name)
        : try await self.storage.uploadImage(data, name: name)
    }
    
    private func uploadTrack(_ data: Data, _ name: String) async throws -> String {
        isTrackFileChanged || areTracksEmpty
        ? try await self.storage.uploadSong(data, name: name)
        : try await self.storage.updateSong(data, name: name)
    }
    
    private func deleteTracksIfNeeded() async throws {
        guard isTrackFileChanged, isEditing else { return }
        guard let tracks = store?.loadedTracks else { return }
        guard let userID = await userProvider.currentUserID?.uuidString else { return }
        for track in tracks {
            try await self.storage.deleteSong(
                name: "\(userID)/\(track.url.lastPathComponent)"
            )
            try await self.database.deleteSong(with: track.serverID)
        }
    }
    
    private func updateSong(_ song: SongDB) async throws -> SongDB? {
        isTrackFileChanged || areTracksEmpty
        ? try await database.upsert(song: song)
        : try await database.update(song: song)
    }
}

// MARK: - Helpers

private extension ConfirmUploadViewModel {
    var areTracksEmpty: Bool {
        store?.loadedTracks.isEmpty ?? true
    }
    
    var areTagsEmpty: Bool {
        store?.tagsAreEmpty ?? true
    }
    
    var isTagUpdateRequired: Bool {
        isEditing &&
        !areTagsEmpty
    }
}
