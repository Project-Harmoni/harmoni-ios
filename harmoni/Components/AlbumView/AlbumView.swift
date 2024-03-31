//
//  AlbumView.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/29/24.
//

import SwiftUI

struct AlbumView: View {
    @ObservedObject var viewModel: AlbumViewModel
    
    var body: some View {
        albumContainer
            .task {
                await viewModel.getAlbum()
                await viewModel.allTagsViewModel.getTags()
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
        List(selection: $viewModel.selectedSongs) {
            Section {
                ForEach($viewModel.songs) { song in
                    HStack(alignment: .center, spacing: 16) {
                        Text("\(song.wrappedValue.ordinal + 1)").foregroundStyle(.gray)
                        Text(song.wrappedValue.name ?? "Song title")
                    }
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
                        songs: viewModel.songs,
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
        if let albumTitle = viewModel.albumTitle {
            VStack(alignment: .center) {
                Text(albumTitle).bold()
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
