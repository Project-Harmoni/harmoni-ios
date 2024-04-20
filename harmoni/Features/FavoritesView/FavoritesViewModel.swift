//
//  FavoritesViewModel.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/19/24.
//

import Foundation

@MainActor class FavoritesViewModel: ObservableObject {
    private let database: DBServiceProviding = DBService()
    private let userProvider: UserProviding = UserProvider()
    @Published var isLoading: Bool = false
    @Published var favoriteSongs: [Song] = []
    
    init() {
        getFavorites()
    }
    
    private func getFavorites() {
        Task.detached { @MainActor [weak self] in
            guard let self else { return }
            guard let currentUserID = await self.userProvider.currentUserID else { return }
            self.isLoading.toggle()
            self.favoriteSongs = try await self.database.likedSongsFor(user: currentUserID.uuidString)
            self.isLoading.toggle()
        }
    }
}
