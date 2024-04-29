//
//  SongCellViewModel.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/12/24.
//

import Foundation

@MainActor class SongCellViewModel: ObservableObject {
    private let database: DBServiceProviding = DBService()
    private let rpc: RPCProviding = RPCProvider()
    private let userProvider: UserProviding = UserProvider()
    @Published var editedSongName: String = ""
    @Published var isAddedToLibrary: Bool = false
    @Published var isLiked: Bool = false
    @Published var song: Song
    
    var queue: [Song] = []
    var isDetailed: Bool = true
    
    init(
        song: Song,
        queue: [Song] = [],
        isDetailed: Bool = false
    ) {
        self.song = song
        self.queue = queue
        self.isDetailed = isDetailed
        self.editedSongName = song.details.name ?? ""
        self.checkState()
    }
    
    private func checkState() {
        Task.detached { @MainActor [weak self] in
            guard let self else { return }
            guard let userID = await userProvider.currentUserID else { return }
            self.isAddedToLibrary = try await self.database.isSongInLibrary(
                self.song.details,
                userID.uuidString
            )
            self.isLiked = try await self.database.isSongLiked(self.song.details, userID.uuidString)
        }
    }
    
    func libraryAction() async {
        do {
            guard let currentUserID = await self.userProvider.currentUserID else { return }
            self.isAddedToLibrary
            ? try await self.database.removeSongFromLibrary(self.song.details, currentUserID.uuidString)
            : try await self.database.addSongToLibrary(
                for: currentUserID.uuidString,
                song: self.song.details
            )
        } catch {
            dump(error)
        }
    }
    
    func likeAction() async {
        do {
            guard let currentUserID = await self.userProvider.currentUserID else { return }
            guard let songID = self.song.details.id else { return }
            self.isLiked
            ? try await self.database.unlikeSong(for: currentUserID.uuidString, song: songID)
            : try await self.database.likeSong(for: currentUserID.uuidString, song: songID)
        } catch {
            dump(error)
        }
    }
    
    func editSongName() async {
        guard let songID = self.song.details.id else { return }
        do {
            try await self.rpc.editTrack(.init(id: songID, name: editedSongName))
            song.details.name = editedSongName
            if let songIndex = queue.firstIndex(where: { $0.id == song.id }) {
                queue[songIndex].details.name = editedSongName
            }
        } catch {
            dump(error)
        }
    }
    
    func deleteSong() async {
        guard let songID = self.song.details.id else { return }
        do {
            try await self.rpc.deleteTrack(.init(id: songID))
        } catch {
            dump(error)
        }
    }
}
