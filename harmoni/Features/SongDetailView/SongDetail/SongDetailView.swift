//
//  SongDetailView.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/16/24.
//

import AlertToast
import Kingfisher
import SwiftUI

struct SongDetailView: View {
    @EnvironmentObject var nowPlayingManager: NowPlayingManager
    @Environment(\.container) var container
    @Environment(\.currentUser) var currentUser
    @StateObject var viewModel: SongDetailViewModel
    @StateObject var audioManager = AudioManager.shared
    @State private var trackBarSize: CGSize = .zero
    @State private var size: CGSize = .zero
    
    var body: some View {
        VStack {
            coverArtContainer
            songInfo
            trackBar
            Spacer()
            actionButtons
            Spacer()
            volumeSlider
            Spacer()
            shareButton
        }
        .padding(.horizontal, 32)
        .presentationCornerRadius(24)
        .presentationDragIndicator(.visible)
        .background(
            ZStack {
                if let path = viewModel.song?.coverImagePath, let url = URL(string: path) {
                    KFImage(url)
                        .placeholder {
                            EmptyView()
                        }
                        .cancelOnDisappear(true)
                        .resizable()
                } else {
                    EmptyView()
                }
                
                Rectangle()
                    .foregroundStyle(.clear)
                    .background(.regularMaterial)
            }
        )
        .toast(
            isPresenting: $viewModel.isPresentingImageToast,
            duration: 1,
            tapToDismiss: true,
            alert: {
                AlertToast(
                    type: .systemImage(viewModel.imageToastSystemName, .primary),
                    title: viewModel.imageToastTitle
                )
            }
        )
        .readSize {
            size = $0
        }
        .onChange(of: nowPlayingManager.song) { _, nowPlayingSong in
            viewModel.song = nowPlayingSong
            viewModel.checkState()
        }
    }
    
    private var coverArtContainer: some View {
        CoverArtView(
            imagePath: viewModel.song?.coverImagePath,
            placeholderName: "music.note",
            size: 325,
            cornerRadius: 8
        )
        .padding(.top, 32)
        .padding(.bottom, 36)
    }
    
    private var songInfo: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Text(viewModel.song?.name ?? "Title")
                    if viewModel.song?.isExplicit ?? false {
                        Image(systemName: "e.square.fill")
                    }
                }
                Text(nowPlayingManager.artistName ?? "Artist")
                    .foregroundStyle(.secondary)
            }
            .bold()
            Spacer()
            if let _ = currentUser {
                Button {
                    Task.detached { @MainActor in
                        await viewModel.likeAction()
                    }
                } label: {
                    Image(systemName: viewModel.isLiked ? "heart.fill" : "heart")
                        .foregroundStyle(.white)
                }
            }
        }
        .padding(.bottom)
    }
    
    private var trackBar: some View {
        VStack {
            ZStack(alignment: .leading) {
                Capsule()
                    .frame(height: 8)
                    .foregroundStyle(.gray.secondary)
                Rectangle()
                    .frame(height: 8)
                    .foregroundStyle(.gray.opacity(0.6))
                    .frame(width: trackBarSize.width * audioManager.elapsedTimeDouble)
                    .clipShape(
                        UnevenRoundedRectangle(
                            cornerRadii: .init(
                                topLeading: 8,
                                bottomLeading: 8
                            )
                        )
                    )
            }
            .animation(.linear, value: audioManager.elapsedTimeDouble)
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .onAppear() {
                            trackBarSize = proxy.size
                        }
                }
            )
            HStack {
                Text(audioManager.elapsedTime)
                Spacer()
                Text(audioManager.timeLeft)
            }
            .font(.caption)
            .foregroundStyle(.gray)
        }
    }
    
    private var actionButtons: some View {
        HStack {
            Button {
                nowPlayingManager.playPrevious()
            } label: {
                Image(systemName: "backward.fill")
                    .tint(.primary)
            }
            .disabled(!nowPlayingManager.isPreviousAvailable)
            .font(.system(size: 24))
            Spacer()
            playPauseButton
            Spacer()
            Button {
                nowPlayingManager.playNext()
            } label: {
                Image(systemName: "forward.fill")
                    .tint(.primary)
            }
            .disabled(!nowPlayingManager.isNextAvailable)
            .font(.system(size: 24))
        }
        .padding(.horizontal, 36)
    }
    
    private var playPauseButton: some View {
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
            .transaction { transaction in
                transaction.animation = nil
            }
        }
        .tint(.primary)
        .font(.system(size: 36))
    }
    
    private var volumeSlider: some View {
        HStack(alignment: .center) {
            Image(systemName: "speaker.fill")
            VolumeSliderView()
                .tint(.secondary)
                .frame(height: 16)
            Image(systemName: "speaker.wave.3.fill")
        }
        .padding(.top)
        .font(.caption)
        .foregroundStyle(.gray)
    }
    
    private var shareButton: some View {
        RoutePickerView()
            .tint(.secondary)
            .frame(height: 32)
    }
}

#Preview {
    SongDetailView(
        viewModel: SongDetailViewModel(song: .mock)
    )
    .environmentObject(NowPlayingManager())
}
