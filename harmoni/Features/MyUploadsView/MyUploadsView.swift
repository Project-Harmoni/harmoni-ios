//
//  MyUploadsView.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/27/24.
//

import SwiftUI

struct MyUploadsView: View {
    @EnvironmentObject var router: AccountViewRouter
    @Environment(\.currentUser) private var currentUser
    @StateObject private var viewModel = MyUploadsViewModel()
    
    var body: some View {
        uploads
            .task {
                viewModel.currentUser = currentUser
                await viewModel.getAlbums()
            }
    }
    
    @ViewBuilder
    private var uploads: some View {
        if viewModel.isLoading {
            ProgressView()
        } else if viewModel.albums.isEmpty {
            Text("**No uploads!** Come back after you've uploaded something.")
                .multilineTextAlignment(.center)
        } else {
            albumList
        }
    }
    
    private var albumList: some View {
        List {
            ForEach(viewModel.albums) { album in
                NavigationLink {
                    AlbumView(
                        viewModel: AlbumViewModel(
                            album: album
                        )
                    )
                } label: {
                    HStack(spacing: 16) {
                        coverArt(for: album)
                        VStack(alignment: .leading) {
                            Text(album.name ?? "Album title").bold()
                            Text(album.yearReleased ?? "Year")
                                .foregroundStyle(.gray)
                        }
                    }
                }
            }
        }
        .navigationTitle("My Uploads")
    }
    
    @ViewBuilder
    private func coverArt(for album: AlbumDB) -> some View {
        CoverArtView(
            imagePath: album.coverImagePath,
            placeholderName: "music.note",
            size: 64,
            cornerRadius: 4
        )
    }
}

#Preview {
    MyUploadsView()
}
