//
//  SongCellViewModel.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/12/24.
//

import Foundation

@MainActor class SongCellViewModel: ObservableObject {
    private let database: DBServiceProviding = DBService()
    private let userProvider: UserProviding = UserProvider()
    @Published var isAddedToLibrary: Bool = false
    @Published var isLiked: Bool = false
    
    var song: Song
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
        self.checkState()
    }
    
    private func checkState() {
        Task.detached { @MainActor [weak self] in
            guard let self else { return }
            self.isAddedToLibrary = try await self.database.isSongInLibrary(self.song.details)
            self.isLiked = try await self.database.isSongLiked(self.song.details)
        }
    }
    
    func libraryAction() async {
        do {
            guard let currentUserID = await self.userProvider.currentUserID else { return }
            self.isAddedToLibrary
            ? try await self.database.removeSongFromLibrary(self.song.details)
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
}
