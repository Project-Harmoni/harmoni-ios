//
//  AccountViewModel.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/9/24.
//

import Combine
import Foundation
import Supabase

class AccountViewModel: ObservableObject {
    /// Registered users have provided birthday and role selection
    @Published var isRegistrationComplete: Bool = false
    @Published var isSignedIn: Bool = false
    @Published var isEditing: Bool = false
    @Published var user: User?
    @Published var listener: ListenerDB?
    @Published var artist: ArtistDB?
    
    // Editable fields
    @Published var name: String = ""
    @Published var bio: String = ""
    @Published var website: String = ""
    
    private var cancellables: Set<AnyCancellable> = []
    private let database: DBServiceProviding = DBService()
    
    init() {
        AuthManager.shared.$isSignedIn
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isSignedIn in
                Task { [weak self] in
                    await self?.handleSignIn(isSignedIn)
                    await self?.getUserType()
                }
            }
            .store(in: &cancellables)
        
        AuthManager.shared.$isRegistrationComplete
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isComplete in
                guard let isComplete else { return }
                self?.isRegistrationComplete = isComplete
            }
            .store(in: &cancellables)
    }
    
    private func handleSignIn(_ isSignedIn: Bool) async {
        self.user = await AuthManager.shared.currentUser
        self.isSignedIn = isSignedIn
    }
    
    /// Retrieves listener or artist based on user UUID
    private func getUserType() async {
        guard let id = user?.id else { return }
        do {
            self.artist = try await self.database.getArtist(with: id)
            self.listener = try await self.database.getListener(with: id)
        } catch {
            dump(error)
        }
    }
}
