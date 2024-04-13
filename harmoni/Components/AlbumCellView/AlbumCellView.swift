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
                    HStack {
                        Text(viewModel.album.name ?? "Album title").bold()
                        if viewModel.album.isExplicit {
                            Image(systemName: "e.square.fill")
                        }
                    }
                    Text(viewModel.album.yearReleased ?? "Year")
                        .foregroundStyle(.gray)
                }
            }
        }
    }
}
