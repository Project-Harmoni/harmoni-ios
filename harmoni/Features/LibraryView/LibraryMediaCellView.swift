//
//  LibraryMediaCellView.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/18/24.
//

import SwiftUI

struct LibraryMediaCellView: View {
    @Environment(\.colorScheme) private var colorScheme
    let song: Song
    let size: CGSize
    
    var body: some View {
        VStack(alignment: .leading) {
            CoverArtView(
                imagePath: song.details.coverImagePath,
                placeholderName: "music.note",
                size: size.width / 2.35,
                cornerRadius: 8
            )
            if let albumName = song.details.albumName {
                Text(albumName)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                    .lineLimit(1)
                    .padding(.trailing, 6)
            }
            Text(song.artistName)
                .foregroundStyle(.gray)
                .lineLimit(1)
        }
    }
}
