//
//  AlbumView.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/29/24.
//

import AlertToast
import SwiftUI

struct AlbumView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.isAdmin) var isAdmin
    @Environment(\.currentUser) var currentUser
    @StateObject var viewModel: AlbumViewModel
    @State private var artistName: String?
    @State private var isDisplayingCopyrightInfringementRequest: Bool = false
    @State private var isDisplayingBlacklistRequest: Bool = false
    
    var body: some View {
        albumContainer
            .task {
                await viewModel.getAlbum()
                await viewModel.allTagsViewModel.getTags()
                artistName = await viewModel.artistName
            }
            .sheet(isPresented: $isDisplayingCopyrightInfringementRequest) {
                if let email = currentUser?.email, let id = viewModel.album.id {
                    SendMailView.copyrightRequest(for: "album " + String(id), from: email)
                }
            }
            .sheet(isPresented: $isDisplayingBlacklistRequest) {
                if let email = currentUser?.email, let id = viewModel.album.id {
                    SendMailView.countryBlacklistRequest(for: "album " + String(id), from: email)
                }
            }
    }
    
    @ViewBuilder
    private var albumContainer: some View {
        if viewModel.isLoading {
            ProgressView()
        } else {
            album
                .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var album: some View {
        List {
            Section {
                ForEach(viewModel.songs) { song in
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
                    Button("Edit", role: .none) {
                        viewModel.isPresentingEdit.toggle()
                    }
                    Button("Delete", role: .destructive) {
                        viewModel.isPresentingDeleteConfirm.toggle()
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
                        Button {
                            isDisplayingBlacklistRequest.toggle()
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
        .sheet(isPresented: $viewModel.isPresentingEdit) {
            NavigationStack {
                UploadView(
                    viewModel: UploadViewModel(
                        album: viewModel.album,
                        songs: viewModel.songs.map { $0.details },
                        tags: viewModel.tags
                    )
                )
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .sheet(isPresented: $viewModel.isPresentingViewTags) {
            AllTagsViewSheet(
                viewModel: viewModel.allTagsViewModel
            )
        }
        .alert("Delete Album", isPresented: $viewModel.isPresentingDeleteConfirm) {
            Button("Cancel", role: .cancel, action: {})
            Button("Delete", role: .destructive, action: {
                Task.detached {
                    await viewModel.deleteAlbum()
                }
            })
        } message: {
            Text("Are you sure you want to delete this album?")
        }
        .toast(
            isPresenting: $viewModel.isDeleted,
            duration: 2,
            tapToDismiss: true,
            alert: {
                AlertToast(type: .complete(.green), title: "Album deleted")
            }, completion: {
                dismiss()
            }
        )
        .toast(isPresenting: $viewModel.isDeleting) {
            AlertToast(
                type: .loading,
                title: "Deleting"
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
            imagePath: viewModel.album.coverImagePath,
            placeholderName: "music.note",
            size: 225,
            cornerRadius: 6
        )
    }
    
    @ViewBuilder
    private var albumInfo: some View {
        if let albumTitle = viewModel.albumTitle, let artistName {
            VStack(alignment: .center) {
                HStack {
                    Text(albumTitle)
                        .bold()
                    if viewModel.album.isExplicit {
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
            if let totalTracksDurationLabel = viewModel.totalTracksDurationLabel {
                Text(totalTracksDurationLabel)
            }
            if let recordLabel = viewModel.recordLabel {
                Text(recordLabel)
            }
            if let yearReleased = viewModel.yearReleased {
                Text(yearReleased)
            }
        }
    }
}

#Preview {
    NavigationStack {
        AlbumView(viewModel: AlbumViewModel(album: AlbumDB(id: 0, name: "Test Album", artistID: "", coverImagePath: "", yearReleased: "2024", totalTracks: 10, recordLabel: "Record Label", duration: 50.46, createdAt: nil)))
    }
}
