//
//  SongDetailView.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/16/24.
//

import SwiftUI

struct SongDetailView: View {
    @StateObject var viewModel = SongDetailViewModel()
    
    var body: some View {
        Button {
            if let url = viewModel.fileURL {
                AudioManager.shared.startAudio(url: url)
                viewModel.isAudioStarted.toggle()
            }
        } label: {
            Text("Start Audio")
        }
        .opacity(viewModel.isAudioStarted ? 0 : 1)
        Button {
            viewModel.isPlaying.toggle()
            viewModel.isPlaying
            ? AudioManager.shared.pause()
            : AudioManager.shared.play()
        } label: {
            Image(systemName: viewModel.isPlaying ? "play.fill" : "pause.fill")
        }
        .opacity(viewModel.isAudioStarted ? 1 : 0)
    }
}

#Preview {
    SongDetailView()
}
