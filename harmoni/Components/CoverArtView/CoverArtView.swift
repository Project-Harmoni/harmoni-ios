//
//  CoverArtView.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/30/24.
//

import SwiftUI

struct CoverArtView: View {
    let imagePath: String?
    let placeholderName: String
    let size: CGFloat
    let cornerRadius: CGFloat
    var body: some View {
        coverArt
    }
    
    @ViewBuilder
    private var coverArt: some View {
        if let coverImagePath = imagePath {
            AsyncImage(url: URL(string: coverImagePath)) { image in
                switch image {
                case .empty:
                    coverArtPlaceholder
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(1, contentMode: .fill)
                        .frame(width: size, height: size)
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
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
        RoundedRectangle(cornerRadius: cornerRadius)
            .foregroundStyle(.gray.tertiary)
            .overlay(
                Image(systemName: placeholderName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size / 2, height: size / 2)
                    .foregroundStyle(.gray)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .frame(width: size, height: size)
    }
}

#Preview {
    CoverArtView(
        imagePath: "",
        placeholderName: "music.note",
        size: 64,
        cornerRadius: 4
    )
}
