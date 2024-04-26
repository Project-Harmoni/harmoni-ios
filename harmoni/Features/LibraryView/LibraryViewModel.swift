//
//  LibraryViewModel.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/18/24.
//

import Foundation

enum LibrarySection: String, CaseIterable, Identifiable {
    var id: String { self.rawValue }
    case artists = "Artists"
    case favorites = "Favorites"
    case recentlyPlayed = "Recently Played"
}

@MainActor class LibraryViewModel: ObservableObject {
    @Published var media: [LibraryItem] = []
    @Published var isLoading: Bool = false
    @Published var isError: Bool = false
    let database: DBServiceProviding = DBService()
    let userProvider: UserProviding = UserProvider()
    
    init() {}
    
    func getLibrary() {
        Task { [weak self] in
            guard let self else { return }
            do {
                guard let currentUserID = await userProvider.currentUserID else { return }
                self.isLoading.toggle()
                media = try await database.getLibrary(for: currentUserID.uuidString)
                self.isLoading.toggle()
            } catch {
                dump(error)
                isError.toggle()
                self.isLoading.toggle()
            }
        }
    }
    
    var sortedMedia: [LibraryItem] {
        media
            .sorted {
                guard let firstDate = $0.date, let secondDate = $1.date else { return true }
                return firstDate > secondDate
            }
    }
}
