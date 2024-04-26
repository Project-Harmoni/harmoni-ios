//
//  NowPlayingBar.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/1/24.
//

import Combine
import Kingfisher
import SwiftUI

enum NowPlayingManagerState {
    case empty
    case single(song: SongDB)
    case startFrom(song: SongDB, in: [SongDB])
    case playAll(songs: [SongDB])
    case shuffle(songs: [SongDB])
}

class NowPlayingManager: ObservableObject {
    @Environment(\.container) var container
    @Published var isPlaying: Bool = false
    @Published var artistName: String?
    @Published var coverImagePath: String?
    @Published var song: SongDB? {
        didSet { play(song) }
    }
    
    private var queue: [SongDB] = []
    private var currentSongIndex: Int = -1 {
        didSet {
            if queue.indices.contains(currentSongIndex) {
                song = queue[currentSongIndex]
            } else {
                isPlaying = false
            }
        }
    }
    
    private let userProvider: UserProviding = UserProvider()
    private let database: DBServiceProviding = DBService()
    private let edge: EdgeProviding = EdgeService()
    private var currentUserID: UUID?
    private var cancellables: Set<AnyCancellable> = []
    
    var state: NowPlayingManagerState = .empty {
        didSet {
            switch state {
            case .empty:
                song = nil
            case .single(let song):
                self.song = song
            case .startFrom(let song, let songs):
                self.setQueue(with: songs, current: song)
            case .playAll(let songs):
                self.setQueue(with: songs)
            case .shuffle(let songs):
                self.setQueue(with: songs.shuffled())
            }
        }
    }
    
    init() {
        AudioManager.shared.onSongFinished = onSongFinished
        AudioManager.shared.onPreviewFinished = onPreviewFinished
        
        AuthManager.shared.$isSignedIn
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    self.currentUserID = await self.userProvider.currentUserID
                }
            }
            .store(in: &cancellables)
    }
    
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
    
    private func setQueue(with songs: [SongDB], current: SongDB? = nil) {
        resetPlayer()
        queue = songs
        if let current, let currentIndex = queue.firstIndex(where: { $0.id == current.id }) {
            currentSongIndex = currentIndex
        } else {
            currentSongIndex = 0
        }
    }
    
    private func onSongFinished() {
        if isNextAvailable {
            playNext()
        } else {
            isPlaying = false
        }
    }
    
    /// Stop audio after preview if user not signed in
    private func onPreviewFinished() {
        guard currentUserID == nil else { return }
        AudioManager.shared.stop()
    }
    
    private func resetPlayer() {
        AudioManager.shared.resetElapsedTime()
    }
    
    /// Play song if token balance is >= 1.
    private func play(_ song: SongDB?) {
        Task.detached { @MainActor [weak self] in
            guard let self else { return }
            guard let songID = song?.id else { return }
            guard let userID = currentUserID?.uuidString else {
                // Preview song for anon users
                return self.playPreview(for: song)
            }
            do {
                self.getReadyToStream(song)
                self.startAudio(for: song)
                
                // Will check token balance and if payout required
                let response = try await self.edge.playSong(
                    request: .init(
                        songID: String(songID),
                        userID: userID
                    )
                )
                
                // Insufficient balance, show error alert
                if let error = response?.error, error.contains("balance") {
                    self.container.isPresentingAlert(
                        title: "Insufficient Balance",
                        message: "You need at least 1 token to play a song."
                    )
                    AudioManager.shared.stop()
                }
            } catch {
                self.container.isPresentingAlert(
                    title: "Unable to Play Song",
                    message: "Please try again."
                )
            }
        }
    }
    
    private func playPreview(for song: SongDB?) {
        getReadyToStream(song)
        startAudio(for: song)
    }
    
    private func getReadyToStream(_ song: SongDB?) {
        getArtistName()
        coverImagePath = song?.coverImagePath
        isPlaying = true
    }
    
    private func startAudio(for song: SongDB?) {
        guard let path = song?.filePath else { return }
        guard let url = URL(string: path) else { return }
        AudioManager.shared.startAudio(url: url)
    }
    
    func playNext() {
        resetPlayer()
        currentSongIndex += 1
    }
    
    func playPrevious() {
        resetPlayer()
        currentSongIndex -= 1
    }
    
    var isNextAvailable: Bool {
        queue.indices.contains(currentSongIndex + 1)
    }
    
    var isPreviousAvailable: Bool {
        queue.indices.contains(currentSongIndex - 1)
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
                CoverArtView(
                    imagePath: nowPlayingManager.coverImagePath,
                    placeholderName: "music.note",
                    size: 36,
                    cornerRadius: 8
                )
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
