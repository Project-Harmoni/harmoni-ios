//
//  SongCellView.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/6/24.
//

import SwiftUI

struct Song: Identifiable {
    let id = UUID()
    var details: SongDB
    var artistName: String
}

class SongCellViewModel: ObservableObject {
    private let database: DBServiceProviding = DBService()
    var song: Song
    var isDetailed: Bool = true
    
    init(
        song: Song,
        isDetailed: Bool = false
    ) {
        self.song = song
        self.isDetailed = isDetailed
    }
}

struct SongCellView: View {
    @EnvironmentObject private var nowPlayingManager: NowPlayingManager
    @ObservedObject var viewModel: SongCellViewModel
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            if !viewModel.isDetailed {
                Text("\(viewModel.song.details.ordinal + 1)").foregroundStyle(.gray)
            }
            if viewModel.isDetailed {
                CoverArtView(
                    imagePath: viewModel.song.details.coverImagePath,
                    placeholderName: "music.note",
                    size: 64,
                    cornerRadius: 8
                )
            }
            VStack(alignment: .leading) {
                HStack {
                    Text(viewModel.song.details.name ?? "Song title")
                    if viewModel.song.details.isExplicit {
                        Image(systemName: "e.square.fill")
                    }
                }
                if viewModel.isDetailed {
                    Text(viewModel.song.artistName)
                        .foregroundStyle(.gray)
                }
            }
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            nowPlayingManager.song = viewModel.song.details
        }
    }
}

#Preview {
    SongCellView(
        viewModel: SongCellViewModel(
            song: .init(details: .mock, artistName: "Test Artist")
        )
    )
    .environmentObject(NowPlayingManager())
}
