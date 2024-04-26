//
//  RecentlyPlayedViewModel.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/25/24.
//

import Foundation

class RecentlyPlayedViewModel: ObservableObject {
    @Published var recentlyPlayed: [Song] = []
    @Published var isLoading: Bool = false
    let database: DBServiceProviding = DBService()
    let userProvider: UserProviding = UserProvider()
    
    init() {
        getRecentlyPlayed()
    }
    
    func getRecentlyPlayed() {
        Task.detached { @MainActor [weak self] in
            guard let self else { return }
            guard let currentUserID = await userProvider.currentUserID else { return }
            self.isLoading.toggle()
            self.recentlyPlayed = try await self.database.getRecentlyPlayedFor(
                user: currentUserID.uuidString
            )
            self.isLoading.toggle()
        }
    }
}
