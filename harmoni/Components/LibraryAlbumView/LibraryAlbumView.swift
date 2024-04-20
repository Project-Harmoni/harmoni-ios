//
//  LibraryAlbumView.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/14/24.
//

import AlertToast
import SwiftUI

// TODO: - Clean-up. Merge with `AlbumView`?

struct LibraryAlbumView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.isAdmin) var isAdmin
    @Environment(\.currentUser) var currentUser
    @StateObject var viewModel: LibraryAlbumViewModel
    
    var body: some View {
        albumContainer
            .task {
                await viewModel.allTagsViewModel?.getTags()
            }
            .sheet(isPresented: $viewModel.isDisplayingCopyrightInfringementRequest) {
                if let email = currentUser?.email, let id = viewModel.albumID {
                    SendMailView.copyrightRequest(for: "album " + String(id), from: email)
                }
            }
            .sheet(isPresented: $viewModel.isDisplayingBlacklistRequest) {
                if let email = currentUser?.email, let id = viewModel.albumID {
                    SendMailView.countryBlacklistRequest(for: "album " + String(id), from: email)
                }
            }
    }
    
    @ViewBuilder
    private var albumContainer: some View {
        album
            .navigationBarTitleDisplayMode(.inline)
    }
    
    private var album: some View {
        List {
            Section {
                ForEach(viewModel.item.songs) { song in
                    SongCellView(
                        viewModel: SongCellViewModel(
                            song: song
                        )
                    )
                    .listRowBackground(Color(.secondarySystemGroupedBackground))
                }
            } header: {
                header
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .textCase(.none)
                    .padding(.bottom)
            } footer: {
                albumFooterInfo
                    .font(.footnote)
                    .padding(.leading, -16)
                    .padding(.top, 8)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    viewModel.isPresentingViewTags.toggle()
                } label: {
                    Image(systemName: "tag")
                }
                Menu {
                    Section {
                        Button(role: .destructive) {
                            viewModel.isPresentingRemoveConfirm.toggle()
                        } label: {
                            HStack {
                                Text("Remove from Library")
                                Spacer()
                                Image(systemName: "trash")
                            }
                        }
                    }
                    Button {
                        viewModel.isDisplayingCopyrightInfringementRequest.toggle()
                    } label: {
                        HStack {
                            Text("Flag for Copyright")
                            Spacer()
                            Image(systemName: "flag")
                        }
                    }
                    if isAdmin {
                        Button {
                            viewModel.isDisplayingBlacklistRequest.toggle()
                        } label: {
                            HStack {
                                Text("Country Blacklist")
                                Spacer()
                                Image(systemName: "slash.circle")
                            }
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                .menuOrder(.fixed)
            }
        }
        .sheet(isPresented: $viewModel.isPresentingViewTags) {
            if let allTagsViewModel = viewModel.allTagsViewModel {
                AllTagsViewSheet(
                    viewModel: allTagsViewModel
                )
            }
        }
        .alert("Remove from Library", isPresented: $viewModel.isPresentingRemoveConfirm) {
            Button("Cancel", role: .cancel, action: {})
            Button("Remove", role: .destructive, action: {
                Task.detached { @MainActor in
                    viewModel.isRemoving.toggle()
                    await viewModel.removeAlbum()
                    viewModel.isRemoving.toggle()
                    viewModel.isRemoved.toggle()
                }
            })
        } message: {
            Text("Are you sure you want to remove this from your library?")
        }
        .toast(
            isPresenting: $viewModel.isRemoved,
            duration: 2,
            tapToDismiss: true,
            alert: {
                AlertToast(type: .complete(.green), title: "Removed")
            }, completion: {
                dismiss()
            }
        )
        .toast(isPresenting: $viewModel.isRemoving) {
            AlertToast(
                type: .loading,
                title: "Removing"
            )
        }
        
    }
    
    private var header: some View {
        HStack {
            Spacer()
            coverArtInfo
            Spacer()
        }
    }
    
    private var coverArtInfo: some View {
        VStack {
            coverArt
            albumInfo
        }
    }
    
    private var coverArt: some View {
        CoverArtView(
            imagePath: viewModel.albumCoverPath,
            placeholderName: "music.note",
            size: 225,
            cornerRadius: 6
        )
    }
    
    @ViewBuilder
    private var albumInfo: some View {
        if let albumTitle = viewModel.albumTitle, let artistName = viewModel.artistName {
            VStack(alignment: .center) {
                HStack {
                    Text(albumTitle)
                        .bold()
                    if let album = viewModel.item.album, album.isExplicit {
                        Image(systemName: "e.square.fill")
                    }
                }
                Text(artistName)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 4)
        }
    }
    
    @ViewBuilder
    private var albumFooterInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(viewModel.totalTracksDurationLabel)
            if let recordLabel = viewModel.recordLabel {
                Text(recordLabel)
            }
            if let yearReleased = viewModel.yearReleased {
                Text(yearReleased)
            }
        }
    }
}
