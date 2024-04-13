//
//  ArtistViewModel.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/7/24.
//

import Foundation

class ArtistViewModel: ObservableObject {
    @MainActor @Published var albums: [AlbumDB] = []
    @MainActor @Published var isLoading: Bool = false
    let artist: ArtistDB
    let database: DBServiceProviding = DBService()
    
    init(artist: ArtistDB) {
        self.artist = artist
    }
    
    @MainActor
    func getAlbums() async {
        do {
            guard albums.isEmpty else { return }
            isLoading.toggle()
            albums = try await database.albumsByArtist(with: artist.id)
            isLoading.toggle()
        } catch {
            dump(error)
            isLoading.toggle()
        }
    }
}
