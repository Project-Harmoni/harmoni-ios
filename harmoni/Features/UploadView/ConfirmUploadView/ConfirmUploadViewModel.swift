//
//  ConfirmUploadViewModel.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/26/24.
//

import UIKit

class ConfirmUploadViewModel: ObservableObject {
    @Published var isSaving: Bool = false
    @Published var isError: Bool = false
    private let database: DBServiceProviding
    private let storage: StorageProviding
    private let userProvider: UserProviding
    private var uploadedSongs: [SongDB] = []
    private var uploadedAlbum: AlbumDB?
    private var uploadedTags: [TagDB] = []
    var store: UploadStore?
    
    init(
        database: DBServiceProviding = DBService(),
        storage: StorageProviding = StorageService(),
        userProvider: UserProviding = UserProvider()
    ) {
        self.database = database
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
                
                // Update tags in database
                try await self.updateTags()
                
                // Upload tracks to storage and update database
                try await self.uploadTracks(for: currentUserID, with: albumCoverPath)
                
                // After tracks, album, and tags are uploaded, update association tables in database
                try await self.updateAssociationTables()
                
                self.isSaving.toggle()
            } catch {
                dump(error)
                self.isSaving.toggle()
                self.isError.toggle()
            }
        }
    }
    
    /// Upload tracks in storage and update database
    private func uploadTracks(for userID: UUID, with coverPath: String) async throws {
        guard let store else { return self.isError.toggle() }
        for track in store.tracks {
            // upload track to storage
            guard let filePath = try await self.upload(track: track) else {
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
            
            if let uploadedSong = try await self.database.upsert(song: song) {
                self.uploadedSongs.append(uploadedSong)
            }
        }
    }
    
    private func upload(track: Track) async throws -> String? {
        guard let store else {
            self.isError.toggle()
            return nil
        }
        let trackData = try Data(contentsOf: track.url)
        guard let trackName = await store.name(for: track) else { return nil }
        let uploadResult = try await self.storage.uploadSong(trackData, name: trackName)
        let trackURL = try self.storage.getMusicURL(for: uploadResult)
        return trackURL.absoluteString
    }
    
    private func uploadCoverArt() async throws -> String? {
        guard let store else {
            self.isError.toggle()
            return nil
        }
        if let albumCoverData = try? await store.albumCoverItem?.loadTransferable(type: Data.self) {
            guard let jpegData = UIImage(data: albumCoverData)?
                .aspectFitToHeight()
                .jpegData(compressionQuality: 0.4)
            else {
                return nil
            }
            guard let albumCoverName = await store.albumCoverName else { return nil }
            // upload image to storage
            let imageLocation = try await self.storage.uploadImage(jpegData, name: albumCoverName)
            // get image name and file extension
            guard let resultPath = URL(string: imageLocation)?.lastPathComponent else {
                return nil
            }
            // get public image url from storage
            let imageURL = try self.storage.getImageURL(for: resultPath)
            return imageURL.absoluteString
        } else {
            return nil
        }
    }
    
    /// Update tags for genres, moods, instruments, and miscellaneous
    private func updateTags() async throws {
        guard let store else { return self.isError.toggle() }
        if let genres = try await self.database.getTagCategory(with: .genres), let id = genres.id {
            for tag in store.genreTagsViewModel.tags {
                let genreTag = TagDB(name: tag.name, categoryID: id)
                if let uploadedTag = try await self.database.upsert(tag: genreTag) {
                    self.uploadedTags.append(uploadedTag)
                }
            }
        }
        
        if let moods = try await self.database.getTagCategory(with: .moods), let id = moods.id {
            for tag in store.moodTagsViewModel.tags {
                let moodTag = TagDB(name: tag.name, categoryID: id)
                if let uploadedTag = try await self.database.upsert(tag: moodTag) {
                    self.uploadedTags.append(uploadedTag)
                }
            }
        }
        
        if let instruments = try await self.database.getTagCategory(with: .instruments), let id = instruments.id {
            for tag in store.instrumentsTagsViewModel.tags {
                let instrumentsTag = TagDB(name: tag.name, categoryID: id)
                if let uploadedTag = try await self.database.upsert(tag: instrumentsTag) {
                    self.uploadedTags.append(uploadedTag)
                }
            }
        }
        
        if let misc = try await self.database.getTagCategory(with: .miscellaneous), let id = misc.id {
            for tag in store.miscTagsViewModel.tags {
                let miscTag = TagDB(name: tag.name, categoryID: id)
                if let uploadedTag = try await self.database.upsert(tag: miscTag) {
                    self.uploadedTags.append(uploadedTag)
                }
            }
        }
    }
    
    /// Update artist table with name, if needed
    private func updateArtistName(with id: UUID) async throws {
        guard let store else { return self.isError.toggle() }
        guard var artist = try await self.database.getArtist(with: id) else {
            return self.isError.toggle()
        }
        if let artistName = artist.name, artistName.isEmpty {
            artist.name = store.artistName
            try await self.database.upsert(artist: artist)
        }
    }
    
    /// Update album in database
    private func updateAlbum(for userID: UUID, with coverPath: String) async throws {
        guard let store else { return self.isError.toggle() }
        let album = AlbumDB(
            name: store.albumTitle,
            artistID: userID,
            coverImagePath: coverPath,
            yearReleased: store.yearReleasedDate,
            totalTracks: store.tracks.count,
            recordLabel: store.recordLabel,
            duration: await store.durationOfTracks,
            createdAt: .now
        )
        self.uploadedAlbum = try await self.database.upsert(album: album)
    }
    
    /// Update song/album table in database
    private func updateSongAlbumAssociations() async throws {
        for uploadedSong in uploadedSongs {
            let songAlbummDB = SongAlbumDB(
                songID: uploadedSong.id,
                albumID: self.uploadedAlbum?.id
            )
            _ = try await self.database.upsert(songAlbum: songAlbummDB)
        }
    }
    
    /// Update song/tag table in database
    private func updateSongTagAssociations() async throws {
        for uploadedSong in uploadedSongs {
            for uploadedTag in uploadedTags {
                let songTagDB = SongTagDB(
                    songID: uploadedSong.id,
                    tagID: uploadedTag.id
                )
                _ = try await self.database.upsert(songTag: songTagDB)
            }
        }
    }
    
    /// After tracks, album, and tags are uploaded, update association tables in database
    private func updateAssociationTables() async throws {
        // Update song/album table in database
        try await self.updateSongAlbumAssociations()
        // Update song/tag table in database
        try await self.updateSongTagAssociations()
    }
    
}
