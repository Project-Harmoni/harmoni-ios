//
//  LibraryArtistsViewModel.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/20/24.
//

import Foundation

@MainActor class LibraryArtistsViewModel: ObservableObject {
    @Published var artists: [ArtistDB] = []
    @Published var isLoading: Bool = false
    private let database: DBServiceProviding = DBService()
    private let userProvider: UserProviding = UserProvider()
    
    init() {
        getLibraryArtists()
    }
    
    private func getLibraryArtists() {
        Task { @MainActor [weak self] in
            guard let self else { return }
            guard let userID = await self.userProvider.currentUserID else { return }
            self.isLoading.toggle()
            self.artists = try await self.database.getLibraryArtists(for: userID.uuidString)
            self.isLoading.toggle()
        }
    }
}
