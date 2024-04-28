//
//  SongDetailViewModel.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/16/24.
//

import Foundation

@MainActor class SongDetailViewModel: ObservableObject {
    private let database: DBServiceProviding = DBService()
    private let userProvider: UserProviding = UserProvider()
    @Published var song: SongDB?
    @Published var isLiked: Bool = false
    @Published var isPresentingImageToast: Bool = false
    @Published var imageToastSystemName: String = ""
    @Published var imageToastTitle: String = ""
    
    init(song: SongDB?) {
        self.song = song
        self.checkState()
    }
    
    func checkState() {
        Task.detached { @MainActor [weak self] in
            guard let self else { return }
            guard let song else { return }
            guard let currentUserID = await self.userProvider.currentUserID else { return }
            self.isLiked = try await self.database.isSongLiked(song, currentUserID.uuidString)
        }
    }
    
    func likeAction() async {
        do {
            guard let currentUserID = await self.userProvider.currentUserID else { return }
            guard let songID = self.song?.id else { return }
            self.isLiked
            ? try await self.database.unlikeSong(for: currentUserID.uuidString, song: songID)
            : try await self.database.likeSong(for: currentUserID.uuidString, song: songID)
            
            self.isPresentingImageToast.toggle()
            self.imageToastSystemName = self.isLiked ? "heart" : "heart.fill"
            self.imageToastTitle = self.isLiked ? "Unfavorited" : "Favorited"
            self.isLiked.toggle()
        } catch {
            dump(error)
        }
    }
}
