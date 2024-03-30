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
                guard viewModel.albums.isEmpty else { return }
                viewModel.currentUser = currentUser
                await viewModel.getAlbums()
            }
    }
    
    @ViewBuilder
    private var uploads: some View {
        if viewModel.isLoading {
            ProgressView()
        } else {
            albumList
        }
    }
    
    private var albumList: some View {
        List {
            ForEach(viewModel.albums) { album in
                NavigationLink {
                    MyAlbumView()
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
        if let coverImagePath = album.coverImagePath {
            AsyncImage(url: URL(string: coverImagePath)) { image in
                switch image {
                case .empty:
                    coverArtPlaceholder
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(1, contentMode: .fill)
                        .frame(width: 64, height: 64)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                case .failure(_):
                    coverArtPlaceholder
                @unknown default:
                    coverArtPlaceholder
                }
            }
        } else {
            coverArtPlaceholder
        }
    }
    
    var coverArtPlaceholder: some View {
        RoundedRectangle(cornerRadius: 4)
            .foregroundStyle(.gray.tertiary)
            .overlay(
                Image(systemName: "music.note")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .foregroundStyle(.gray)
            )
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .frame(width: 64, height: 64)
    }
}

#Preview {
    MyUploadsView()
}
