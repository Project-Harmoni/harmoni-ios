//
//  SongCellViewModel.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/12/24.
//

import Foundation

class SongCellViewModel: ObservableObject {
    private let database: DBServiceProviding = DBService()
    private let userProvider: UserProviding = UserProvider()
    @MainActor @Published var isAddedToLibrary: Bool = false
    var song: Song
    var isDetailed: Bool = true
    
    init(
        song: Song,
        isDetailed: Bool = false
    ) {
        self.song = song
        self.isDetailed = isDetailed
        self.checkIfInLibrary()
    }
    
    private func checkIfInLibrary() {
        Task.detached { @MainActor [weak self] in
            guard let self else { return }
            self.isAddedToLibrary = try await self.database.isSongInLibrary(self.song.details)
        }
    }
    
    func libraryAction() {
        Task.detached { @MainActor [weak self] in
            guard let self else { return }
            guard let currentUserID = await self.userProvider.currentUserID else { return }
            self.isAddedToLibrary
            ? try await self.database.removeSongFromLibrary(self.song.details)
            : try await self.database.addSongToLibrary(
                for: currentUserID.uuidString,
                song: self.song.details
            )
        }
    }
}
