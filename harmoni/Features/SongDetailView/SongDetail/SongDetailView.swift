//
//  SongDetailView.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/16/24.
//

import SwiftUI

struct SongDetailView: View {
    @EnvironmentObject var nowPlayingManager: NowPlayingManager
    @ObservedObject var viewModel: SongDetailViewModel
    
    var body: some View {
        Button {
            nowPlayingManager.isPlaying.toggle()
            nowPlayingManager.isPlaying
            ? AudioManager.shared.pause()
            : AudioManager.shared.play()
        } label: {
            Image(
                systemName: nowPlayingManager.isPlaying
                ? "play.fill"
                : "pause.fill"
            )
        }
    }
}

#Preview {
    SongDetailView(
        viewModel: SongDetailViewModel(fileURL: nil)
    )
}
