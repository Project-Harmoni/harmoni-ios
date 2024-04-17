//
//  ArtistCellView.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/7/24.
//

import Kingfisher
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
            .padding(32)
            .scaledToFit()
            .foregroundStyle(.white)
    }
}
