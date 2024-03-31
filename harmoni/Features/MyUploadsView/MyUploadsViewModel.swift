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
    @MainActor @Published var isError: Bool = false
    @MainActor @Published var isLoading: Bool = false
    let database: DBServiceProviding = DBService()
    var currentUser: User?
    
    @MainActor
    func getAlbums() async {
        guard albums.isEmpty else { return }
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
}
