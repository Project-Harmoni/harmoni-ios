//
//  LibraryViewModel.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/18/24.
//

import Foundation

@MainActor class LibraryViewModel: ObservableObject {
    @Published var media: [LibraryItem] = []
    @Published var isError: Bool = false
    let database: DBServiceProviding = DBService()
    let userProvider: UserProviding = UserProvider()
    
    func getLibrary() {
        Task { [weak self] in
            guard let self else { return }
            do {
                guard let currentUserID = await userProvider.currentUserID else { return }
                media = try await database.getLibrary(for: currentUserID.uuidString)
            } catch {
                dump(error)
                isError.toggle()
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
