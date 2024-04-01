//
//  MyUploadsViewModel.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/29/24.
//

import Foundation
import Supabase

class MyUploadsViewModel: ObservableObject {
    @MainActor @Published var albums: [AlbumDB] = []
    @MainActor @Published var selectedAlbums: Set<AlbumDB.ID> = []
    @MainActor @Published var isShowingDeleteConfirm: Bool = false
    @MainActor @Published var isDeleting: Bool = false
    @MainActor @Published var isDeleted: Bool = false
    @MainActor @Published var isError: Bool = false
    @MainActor @Published var isLoading: Bool = false
    @MainActor @Published var isSelectingAll: Bool = false
    let database: DBServiceProviding = DBService()
    let storage: StorageProviding = StorageService()
    var currentUser: User?
    
    @MainActor
    func getAlbums() async {
        guard albums.isEmpty else { return }
        await reload()
    }
    
    @MainActor
    func reload() async {
        guard !isLoading else { return }
        isLoading.toggle()
        guard let currentUser else { return isError.toggle() }
        do {
            albums = try await database.albumsByArtist(with: currentUser.id)
            isLoading.toggle()
        } catch {
            dump(error)
            isError.toggle()
            isLoading.toggle()
        }
    }
    
    func deleteSelected() {
        Task.detached { @MainActor [weak self] in
            guard let self else { return }
            self.isDeleting.toggle()
            do {
                let albumsToDelete: [Int8?] = albums
                    .filter { album in
                        self.selectedAlbums.contains(where: { $0 == album.id })
                    }
                    .map { $0.id }
                try await database.deleteAlbums(with: albumsToDelete, in: storage)
                self.isDeleting.toggle()
                self.isDeleted.toggle()
            } catch {
                dump(error)
                self.isError.toggle()
                self.isDeleting.toggle()
            }
        }
    }
}
