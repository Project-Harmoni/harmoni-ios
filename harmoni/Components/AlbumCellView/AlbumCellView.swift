//
//  AlbumCellView.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/7/24.
//

import SwiftUI

struct AlbumCellView: View {
    @StateObject var viewModel: AlbumViewModel
    
    var body: some View {
        NavigationLink {
            AlbumView(viewModel: viewModel)
        } label: {
            HStack(spacing: 16) {
                CoverArtView(
                    imagePath: viewModel.album.coverImagePath,
                    placeholderName: "music.note",
                    size: 64,
                    cornerRadius: 4
                )
                VStack(alignment: .leading) {
                    Text(viewModel.album.name ?? "Album title").bold()
                    Text(viewModel.album.yearReleased ?? "Year")
                        .foregroundStyle(.gray)
                }
            }
        }
    }
}
