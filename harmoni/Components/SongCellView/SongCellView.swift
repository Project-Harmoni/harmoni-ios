//
//  SongCellView.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/6/24.
//

import SwiftUI

class SongCellViewModel: ObservableObject {
    var song: SongDB
    
    init(song: SongDB) {
        self.song = song
    }
}

struct SongCellView: View {
    @EnvironmentObject var nowPlayingManager: NowPlayingManager
    @ObservedObject var viewModel: SongCellViewModel
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Text("\(viewModel.song.ordinal + 1)").foregroundStyle(.gray)
            Text(viewModel.song.name ?? "Song title")
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            nowPlayingManager.song = viewModel.song
        }
    }
}

#Preview {
    SongCellView(
        viewModel: SongCellViewModel(
            song: .mock
        )
    )
    .environmentObject(NowPlayingManager())
}
