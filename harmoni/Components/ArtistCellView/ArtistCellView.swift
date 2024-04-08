//
//  ArtistCellView.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/7/24.
//

import SwiftUI

struct ArtistCellView: View {
    @ObservedObject var viewModel: ArtistViewModel
    
    var body: some View {
        NavigationLink {
            ArtistView(viewModel: viewModel)
        } label: {
            HStack(spacing: 16) {
                profilePicture
                Text(viewModel.artist.name ?? "Artist")
            }
        }
    }
    
    private var profilePicture: some View {
        Circle()
            .frame(height: 64)
            .foregroundStyle(.gray)
            .overlay {
                profileImage
            }
    }
    
    @ViewBuilder
    private var profileImage: some View {
        if let imageURL = viewModel.artist.imageURL {
            AsyncImage(url: URL(string: imageURL)) { image in
                switch image {
                case .empty:
                    profileImagePlaceholder
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                case .failure(_):
                    profileImagePlaceholder
                @unknown default:
                    profileImagePlaceholder
                }
            }
        }
    }
    
    private var profileImagePlaceholder: some View {
        Image(systemName: "person")
            .resizable()
            .padding(32)
            .scaledToFit()
            .foregroundStyle(.white)
    }
}
