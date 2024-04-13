//
//  AppContainerViewModel.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/9/24.
//

import Combine
import Foundation
import Supabase

class AppContainerViewModel: ObservableObject {
    @Published var isArtist: Bool = false
    @Published var isAdmin: Bool = false
    @Published var isNew: Bool = false
    @Published var currentUser: User?
    private var userProvider: UserProviding = UserProvider()
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        AuthManager.shared.$isSignedIn
             .receive(on: DispatchQueue.main)
             .sink { [weak self] _ in
                 self?.checkPermissions()
             }
             .store(in: &cancellables)
        
        AuthManager.shared.$isRegistrationComplete
             .receive(on: DispatchQueue.main)
             .sink { [weak self] isComplete in
                 guard let isComplete, isComplete else { return }
                 self?.checkPermissions()
             }
             .store(in: &cancellables)
    }
    
    private func checkPermissions() {
        Task { @MainActor [weak self] in
            self?.isArtist = await self?.userProvider.isArtist ?? false
            self?.isAdmin = await self?.userProvider.isAdmin ?? false
            self?.isNew = await self?.userProvider.isNew ?? false
            self?.currentUser = await self?.userProvider.currentUser
        }
    }
}
