//
//  ArtistView.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/7/24.
//

import Kingfisher
import SwiftUI

struct ArtistView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: ArtistViewModel
    
    var body: some View {
        NavigationStack {
            if viewModel.isLoading {
                ProgressView()
            } else {
                artist
            }
        }
        .task {
            await viewModel.getAlbums()
        }
        .navigationTitle(viewModel.artist.name ?? "")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var artist: some View {
        List {
            Section {
                ForEach(viewModel.albums) { album in
                    AlbumCellView(viewModel: AlbumViewModel(album: album))
                }
            } header: {
                header
            }
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                profilePicture
                Spacer()
            }
            Spacer()
                .frame(height: 28)
            Text("Albums").bold()
        }
    }
    
    private var profilePicture: some View {
        Circle()
            .frame(height: 150)
            .foregroundStyle(.gray)
            .overlay {
                profileImage
            }
    }
    
    @ViewBuilder
    private var profileImage: some View {
        if let path = viewModel.artist.imageURL, let url = URL(string: path) {
            KFImage(url)
                .placeholder {
                    profileImagePlaceholder
                }
                .cancelOnDisappear(true)
                .resizable()
                .scaledToFill()
                .clipShape(Circle())
        } else {
            profileImagePlaceholder
        }
    }
    
    private var profileImagePlaceholder: some View {
        Image(systemName: "person")
            .resizable()
            .padding(112)
            .scaledToFit()
            .foregroundStyle(.white)
    }
}
