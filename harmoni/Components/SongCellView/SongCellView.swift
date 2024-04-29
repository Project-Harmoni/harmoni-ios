//
//  SongCellView.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/6/24.
//

import SwiftUI

struct SongCellView: View {
    @EnvironmentObject private var nowPlayingManager: NowPlayingManager
    @Environment(\.container) var container
    @Environment(\.isAdmin) var isAdmin
    @Environment(\.currentUser) var currentUser
    @StateObject var viewModel: SongCellViewModel
    @State private var isDisplayingCopyrightInfringementRequest: Bool = false
    @State private var isDisplayingBlacklistRequest: Bool = false
    @State private var isDisplayingEditSongAlert: Bool = false
    @State private var isDisplayingDeleteSongAlert: Bool = false
    
    var body: some View {
        song
            .sheet(isPresented: $isDisplayingCopyrightInfringementRequest) {
                if let email = currentUser?.email {
                    SendMailView.copyrightRequest(for: "song " + viewModel.song.id.uuidString, from: email)
                }
            }
            .sheet(isPresented: $isDisplayingBlacklistRequest) {
                if let email = currentUser?.email {
                    SendMailView.countryBlacklistRequest(for: "song " + viewModel.song.id.uuidString, from: email)
                }
            }
            .alert(
                "Edit Song",
                isPresented: $isDisplayingEditSongAlert
            ) {
                TextField("Edit name", text: $viewModel.editedSongName)
                Button("Cancel", role: .cancel, action: {})
                Button("Delete", role: .destructive, action: {
                    isDisplayingDeleteSongAlert.toggle()
                })
                Button("Save", role: .none, action: {
                    Task.detached { @MainActor in
                        await viewModel.editSongName()
                    }
                })
            } message: {}
            .alert(
                "Delete Song?",
                isPresented: $isDisplayingDeleteSongAlert
            ) {
                Button("Cancel", role: .cancel, action: {})
                Button("Delete", role: .destructive, action: {
                    Task.detached { @MainActor in
                        container.isPresentingLoadingToast(
                            title: "Deleting"
                        )
                        await viewModel.deleteSong()
                        container.isPresentingSuccessToast(
                            title: "Deleted"
                        ) {}
                    }
                })
            } message: {}
    }
    
    private var song: some View {
        HStack(alignment: .center, spacing: 16) {
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
                if viewModel.queue.isEmpty {
                    nowPlayingManager.state = .single(song: viewModel.song.details)
                } else {
                    nowPlayingManager.state = .startFrom(
                        song: viewModel.song.details,
                        in: viewModel.queue.map { $0.details }
                    )
                }
            }
            menu
        }
    }
    
    private var menu: some View {
        Menu {
            if let _ = currentUser {
                Section {
                    Button {
                        Task.detached { @MainActor in
                            await viewModel.likeAction()
                            container.isPresentingImageToast(
                                systemName: viewModel.isLiked ? "heart" : "heart.fill",
                                title: viewModel.isLiked ? "Unfavorited" : "Favorited"
                            ) {
                                viewModel.isLiked.toggle()
                            }
                        }
                    } label: {
                        HStack {
                            Text(viewModel.isLiked ? "Unfavorite" : "Favorite")
                            Spacer()
                            Image(systemName: viewModel.isLiked ? "heart.fill" : "heart")
                        }
                    }
                    Button(role: viewModel.isAddedToLibrary ? .destructive : .none) {
                        Task.detached { @MainActor in
                            container.isPresentingLoadingToast(
                                title: viewModel.isAddedToLibrary ? "Removing" : "Adding"
                            )
                            await viewModel.libraryAction()
                            container.isPresentingSuccessToast(
                                title: viewModel.isAddedToLibrary ? "Removed from Library" : "Added to Library"
                            ) {
                                viewModel.isAddedToLibrary.toggle()
                            }
                        }
                    } label: {
                        HStack {
                            Text(viewModel.isAddedToLibrary ? "Remove from Library" : "Add to Library")
                            Spacer()
                            Image(systemName: viewModel.isAddedToLibrary ? "trash" : "plus")
                        }
                    }
                }
            }
            Button {
                isDisplayingCopyrightInfringementRequest.toggle()
            } label: {
                HStack {
                    Text("Flag for Copyright")
                    Spacer()
                    Image(systemName: "flag")
                }
            }
            if isAdmin {
                Section("Admin") {
                    Button {
                        isDisplayingBlacklistRequest.toggle()
                    } label: {
                        HStack {
                            Text("Country Blacklist")
                            Spacer()
                            Image(systemName: "slash.circle")
                        }
                    }
                    Button {
                        isDisplayingEditSongAlert.toggle()
                    } label: {
                        HStack {
                            Text("Edit Song")
                            Spacer()
                            Image(systemName: "pencil")
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "ellipsis")
                .tint(.primary)
                .frame(height: viewModel.isDetailed ? 64 : 32)
        }
    }
}

#Preview {
    SongCellView(
        viewModel: SongCellViewModel(
            song: .init(details: .mock, artistName: "Test Artist")
        )
    )
}
