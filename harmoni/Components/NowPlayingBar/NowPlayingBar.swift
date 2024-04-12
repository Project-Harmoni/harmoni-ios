//
//  NowPlayingBar.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/1/24.
//

import SwiftUI

class NowPlayingManager: ObservableObject {
    @Published var isPlaying: Bool = false
    @Published var artistName: String?
    @Published var coverImagePath: String?
    @Published var song: SongDB? {
        didSet {
            guard let path = song?.filePath else { return }
            guard let url = URL(string: path) else { return }
            getArtistName()
            coverImagePath = song?.coverImagePath
            isPlaying = true
            AudioManager.shared.startAudio(url: url)
        }
    }
    private let database: DBServiceProviding = DBService()
    
    private func getArtistName() {
        Task { @MainActor [weak self] in
            guard let self else { return }
            guard let artistID = song?.artistID else { return }
            guard let artistUUID = UUID(uuidString: artistID) else { return }
            do {
                let artist = try await database.getArtist(with: artistUUID)
                artistName = artist?.name
            } catch {
                dump(error)
            }
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
        if let name = nowPlayingManager.song?.name {
            HStack {
                HStack {
                    Text(name)
                    if nowPlayingManager.song?.isExplicit ?? false {
                        Image(systemName: "e.square.fill")
                    }
                }
                Spacer()
                Button {
                    nowPlayingManager.isPlaying.toggle()
                    nowPlayingManager.isPlaying
                    ? AudioManager.shared.play()
                    : AudioManager.shared.pause()
                } label: {
                    Image(
                        systemName: nowPlayingManager.isPlaying
                        ? "pause.fill"
                        : "play.fill"
                    )
                    .tint(.primary)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                viewModel.isPresentingSongDetail.toggle()
            }
            .sheet(isPresented: $viewModel.isPresentingSongDetail) {
                SongDetailView(
                    viewModel: SongDetailViewModel(
                        song: nowPlayingManager.song
                    )
                )
            }
            .onAppear() {
                AudioManager.shared.onSongFinished = {
                    nowPlayingManager.isPlaying = false
                }
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
