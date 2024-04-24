//
//  AccountViewModel.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/9/24.
//

import Combine
import PhotosUI
import SwiftUI
import Supabase

@MainActor class AccountViewModel: ObservableObject {
    /// Registered users have provided birthday and role selection
    @Published var isRegistrationComplete: Bool = false
    @Published var isDisplayingWelcomeView: Bool = false
    @Published var isDisplayingTokenPurchase: Bool = false
    @Published var isSignedIn: Bool = false
    @Published var isEditing: Bool = false
    @Published var isError: Bool = false
    @Published var isSaving: Bool = false
    @Published var user: User?
    @Published var listener: ListenerDB?
    @Published var artist: ArtistDB?
    @Published var profileImageItem: PhotosPickerItem?
    @Published var profileImage: URL?
    @Published var justChangedProfileImage: Image?
    @Published var tokens: Float = 0
    
    // Editable fields
    @Published var name: String = ""
    @Published var bio: String = ""
    @Published var website: String = ""
    
    private var cancellables: Set<AnyCancellable> = []
    private let database: DBServiceProviding = DBService()
    private let storage: StorageProviding = StorageService()
    private let edge: EdgeProviding = EdgeService()
    private let userProvider: UserProviding = UserProvider()
    
    init() {
        AuthManager.shared.$isSignedIn
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isSignedIn in
                Task { [weak self] in
                    await self?.handleSignIn(isSignedIn)
                    await self?.handleAccountData()
                }
            }
            .store(in: &cancellables)
        
        AuthManager.shared.$isRegistrationComplete
            .receive(on: DispatchQueue.main)
            .sink { isComplete in
                guard let isComplete else { return }
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    self.isRegistrationComplete = isComplete
                    self.isDisplayingWelcomeView = await self.userProvider.isNew
                }
            }
            .store(in: &cancellables)
        
        $profileImageItem
            .receive(on: DispatchQueue.main)
            .sink { [weak self] item in
                guard let item else { return }
                Task.detached { [weak self] in
                    /// handle chosen profile image
                   try await self?.handle(picked: item)
                }
            }
            .store(in: &cancellables)
    }
    
    private func handleSignIn(_ isSignedIn: Bool) async {
        self.user = await AuthManager.shared.currentUser
        self.isSignedIn = isSignedIn
        self.isDisplayingWelcomeView = await self.userProvider.isNew
    }
    
    private func toggleError(_ toggle: Bool) {
        isError = toggle
    }
    
    func actionButtonTapped() {
        Task.detached(priority: .utility) { @MainActor [weak self] in
            guard let self else { return }
            do {
                if self.isEditing {
                    self.isSaving.toggle()
                    try await self.upsertArtist()
                    try await self.upsertListener()
                    self.isSaving.toggle()
                    self.isEditing.toggle()
                } else {
                    self.isEditing.toggle()
                }
            } catch {
                dump(error)
                self.isError = true
            }
        }
    }
    
    func logout() async {
        await AuthManager.shared.logout()
        UserDefaults.standard.set(false, forKey: "isAdminRequested")
        profileImage = nil
        profileImageItem = nil
        justChangedProfileImage = nil
        name = ""
        bio = ""
        website = ""
        tokens = 0
    }
}

// MARK: Upsert database

private extension AccountViewModel {
    func upsertArtist() async throws {
        if name.isEmpty, bio.isEmpty, website.isEmpty { return }
        guard var artist else { return }
        artist.name = name
        artist.biography = bio
        artist.socialLinkURL = website
        self.artist = artist
        try await self.database.upsert(artist: artist)
    }
    
    func upsertListener() async throws {
        if name.isEmpty { return }
        guard var listener else { return }
        listener.name = name
        self.listener = listener
        try await self.database.upsert(listener: listener)
    }
    
    func upsertProfileImage(location: String) async throws {
        if var artist {
            artist.imageURL = location
            try await database.upsert(artist: artist)
        }
        
        if var listener {
            listener.imageURL = location
            try await database.upsert(listener: listener)
        }
    }
}

// MARK: - Get data from database

extension AccountViewModel {
    /// Get all data associated with current user
    func handleAccountData() async {
        guard let id = user?.id else { return }
        do {
            artist = try await database.getArtist(with: id)
            listener = try await database.getListener(with: id)
            handleArtistData()
            handleListenerData()
        } catch {
            dump(error)
        }
    }
    
    private func handleArtistData() {
        guard let artist else { return }
        name = artist.name ?? ""
        bio = artist.biography ?? ""
        website = artist.socialLinkURL ?? ""
        tokens = artist.tokens
        if let imageURL = artist.imageURL {
            profileImage = URL(string: imageURL)
        }
    }
    
    private func handleListenerData() {
        guard let listener else { return }
        name = listener.name ?? ""
        tokens = listener.tokens
        if let imageURL = listener.imageURL {
            profileImage = URL(string: imageURL)
        }
    }
}

// MARK: - Profile picture

private extension AccountViewModel {
    /// Convert chosen profile picture item as image
    func handle(picked item: PhotosPickerItem) async throws {
        // update locally immediately
        if let data = try? await item.loadTransferable(type: Data.self),
           let uiImage = UIImage(data: data) {
            await MainActor.run { [weak self] in
                self?.justChangedProfileImage = Image(uiImage: uiImage)
            }
        }
        
        // update backend storage, database
        if let data = try? await item.loadTransferable(type: Data.self) {
            guard let jpegData = UIImage(data: data)?
                .aspectFitToHeight()
                .jpegData(compressionQuality: 0.2)
            else {
                return toggleError(true)
            }
            guard let profileImageName else {
                return toggleError(true)
            }
            
            try await self.uploadProfileImage(jpegData, name: profileImageName)
        } else {
            return toggleError(true)
        }
    }
    
    func uploadProfileImage(_ data: Data, name: String) async throws {
        do {
            // upload image to storage
            let imageLocation = try await storage.uploadImage(data, name: name)
            // get image name and file extension
            guard let resultPath = URL(string: imageLocation)?.lastPathComponent else {
                return toggleError(true)
            }
            // get public image url from storage
            let imageURL = try storage.getImageURL(for: resultPath)
            // update database with public image url
            try await upsertProfileImage(location: imageURL.absoluteString)
            
            await MainActor.run { [weak self] in
                // update image in view
                self?.profileImage = imageURL
            }
        } catch {
            dump(error)
            return toggleError(true)
        }
    }
    
    var profileImageName: String? {
        guard let user else { return nil }
        let uuid = user.id.uuidString
        return "\(uuid)_profile_image".toJPG
    }
}

// MARK: - Purchase Tokens

extension AccountViewModel {
    func purchaseTokens() {
        Task { @MainActor [weak self] in
            guard let self else { return }
            guard let user = self.user else { return }
            let purchase = try await self.edge.purchaseTokens(
                request: .init(
                    userID: user.id.uuidString,
                    tokenQuantity: 1000.toString
                )
            )
            
            if purchase?.error == nil {
                await self.handleAccountData()
                self.isDisplayingTokenPurchase.toggle()
            } else {
                self.isError.toggle()
            }
        }
    }
}

