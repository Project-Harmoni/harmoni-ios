//
//  CoverArtView.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/30/24.
//

import Kingfisher
import SwiftUI

struct CoverArtView: View {
    var imagePath: String?
    let placeholderName: String
    var size: CGFloat = .zero
    let cornerRadius: CGFloat
    var body: some View {
        coverArt
    }
    
    @ViewBuilder
    private var coverArt: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .frame(width: size, height: size)
            .foregroundStyle(.gray.tertiary)
            .overlay {
                if let imagePath, let url = URL(string: imagePath) {
                    KFImage(url)
                        .placeholder {
                            coverArtPlaceholder
                        }
                        .cancelOnDisappear(true)
                        .resizable()
                        .scaledToFill()
                        .frame(width: size, height: size)
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                } else {
                    coverArtPlaceholder
                }
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
