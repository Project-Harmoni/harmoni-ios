//
//  NowPlayingBar.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/1/24.
//

import SwiftUI

class NowPlayingManager: ObservableObject {
    @Published var isPlaying: Bool = false
    @Published var track: Track? {
        didSet {
            guard let url = track?.url else { return }
            AudioManager.shared.startAudio(url: url)
        }
    }
}

class NowPlayingViewModel: ObservableObject {
    @Published var isPresentingSongDetail: Bool = false
}

struct NowPlayingBar: View {
    @EnvironmentObject var nowPlayingManager: NowPlayingManager
    @StateObject var viewModel = NowPlayingViewModel()
    
    var body: some View {
        if let track = nowPlayingManager.track {
            HStack {
                Text(track.name)
                Spacer()
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
            .contentShape(Rectangle())
            .onTapGesture {
                viewModel.isPresentingSongDetail.toggle()
            }
            .sheet(isPresented: $viewModel.isPresentingSongDetail) {
                SongDetailView(
                    viewModel: SongDetailViewModel(
                        fileURL: nowPlayingManager.track?.url
                    )
                )
            }
        } else {
            Text("Nothing playing")
        }
    }
}

#Preview {
    NowPlayingBar()
        .environmentObject(NowPlayingManager())
}
