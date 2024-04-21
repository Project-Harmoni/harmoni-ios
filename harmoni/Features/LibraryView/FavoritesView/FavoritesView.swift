//
//  FavoritesView.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/19/24.
//

import SwiftUI

struct FavoritesView: View {
    @StateObject private var viewModel = FavoritesViewModel()
    
    var body: some View {
        favorites
            .navigationTitle("Favorites")
    }
    
    @ViewBuilder
    private var favorites: some View {
        if viewModel.isLoading {
            ProgressView("Loading")
        } else if viewModel.favoriteSongs.isEmpty {
            Text("**What's your favorite music?**\nCome back after favoriting a song.")
                .multilineTextAlignment(.center)
        } else {
            List {
                ForEach(viewModel.favoriteSongs) { song in
                    SongCellView(
                        viewModel: .init(
                            song: song,
                            queue: viewModel.favoriteSongs,
                            isDetailed: true
                        )
                    )
                }
            }
        }
    }
}

#Preview {
    FavoritesView()
}
