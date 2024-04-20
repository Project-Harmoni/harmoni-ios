//
//  LibraryArtistsView.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/20/24.
//

import SwiftUI

struct LibraryArtistsView: View {
    @StateObject private var viewModel = LibraryArtistsViewModel()
    
    var body: some View {
        artists
            .navigationTitle("Artists")
    }
    
    @ViewBuilder
    private var artists: some View {
        if viewModel.isLoading {
            ProgressView("Loading")
        } else if viewModel.artists.isEmpty {
            Text("**No Artists.** Add music to your library.")
        } else {
            List {
                ForEach(viewModel.artists) { artist in
                    ArtistCellView(
                        viewModel: .init(
                            artist: artist
                        )
                    )
                }
            }
        }
    }
}

#Preview {
    LibraryArtistsView()
}
