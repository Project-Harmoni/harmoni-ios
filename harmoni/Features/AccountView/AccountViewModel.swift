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

class AccountViewModel: ObservableObject {
    /// Registered users have provided birthday and role selection
    @Published var isRegistrationComplete: Bool = false
    @Published var isSignedIn: Bool = false
    @Published var isEditing: Bool = false
    @Published var isError: Bool = false
    @Published var user: User?
    @Published var listener: ListenerDB?
    @Published var artist: ArtistDB?
    @Published var profileImageItem: PhotosPickerItem?
    @Published var profileImage: URL?
    @Published var tokens: Int = 0
    
    // Editable fields
    @Published var name: String = ""
    @Published var bio: String = ""
    @Published var website: String = ""
    
    private var cancellables: Set<AnyCancellable> = []
    private let database: DBServiceProviding = DBService()
    private let storage: StorageProviding = StorageService()
    
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
            .sink { [weak self] isComplete in
                guard let isComplete else { return }
                self?.isRegistrationComplete = isComplete
            }
            .store(in: &cancellables)
        
        $profileImageItem
            .receive(on: DispatchQueue.main)
            .sink { [weak self] item in
                guard let item else { return }
                /// handle chosen profile image
                self?.handle(picked: item)
            }
            .store(in: &cancellables)
    }
    
    @MainActor
    private func handleSignIn(_ isSignedIn: Bool) async {
        self.user = await AuthManager.shared.currentUser
        self.isSignedIn = isSignedIn
    }
    
    /// Convert chosen profile picture item as image
    private func handle(picked item: PhotosPickerItem) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            if let data = try? await item.loadTransferable(type: Data.self) {
                let reducedImage = UIImage(data: data)?.aspectFitToHeight() // 200 height by default
                let jpegData = reducedImage?.jpegData(compressionQuality: 0.2) // compress image
                guard let jpegData else {
                    return self.isError = true
                }
                guard let profileImageName else { 
                    return self.isError = true
                }
                self.uploadProfileImage(jpegData, name: profileImageName)
            } else {
                self.isError = true
            }
        }
    }
    
    /// Get all data associated with current user
    @MainActor
    private func handleAccountData() async {
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
    
    private func uploadProfileImage(_ data: Data, name: String) {
        Task(priority: .utility) { @MainActor [weak self] in
            do {
                guard let result = try await self?.storage.uploadImage(data, name: name) else {
                    return self?.isError = true
                }
                guard let resultPath = URL(string: result)?.lastPathComponent else {
                    return self?.isError = true
                }
                self?.profileImage = try self?.storage.getImageURL(for: resultPath)
            } catch {
                dump(error)
                self?.isError = true
            }
        }
    }
    
    private var profileImageName: String? {
        guard let user else { return nil }
        let uuid = user.id.uuidString
        return "\(uuid)_profile_image.jpg"
    }
    
    func actionButtonTapped() {
        if isEditing {
            // other stuff
            isEditing.toggle()
        } else {
            isEditing.toggle()
        }
    }
}
