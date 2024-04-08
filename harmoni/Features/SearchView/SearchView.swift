//
//  SearchView.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/6/24.
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject var nowPlayingManager: NowPlayingManager
    @StateObject var viewModel = SearchViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                taggedSongs
                songsThatMatch
                albumsThatMatch
                artistsThatMatch
                latestSongs
            }
            .searchable(
                text: $viewModel.searchString,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: Text("Artists, Songs, Albums, and #Tags")
            )
            .refreshable {
                await viewModel.getLatestSongs(force: true)
            }
            .task {
                await viewModel.getLatestSongs()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.isShowingInfoPopover.toggle()
                    } label: {
                        Image(systemName: "info.circle")
                    }
                    .popover(isPresented: $viewModel.isShowingInfoPopover) {
                        Text("Search Tags by prefixing with # sign. For example, #jazz will search for songs tagged with 'jazz'.")
                            .font(.caption)
                            .padding()
                            .presentationCompactAdaptation(.popover)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Search")
        }
    }
    
    @ViewBuilder
    private var latestSongs: some View {
        if viewModel.latestSongs.isNotEmpty {
            Section("Latest") {
                ForEach(viewModel.latestSongs) { song in
                    SongCellView(
                        viewModel: SongCellViewModel(
                            song: song,
                            isDetailed: true
                        )
                    )
                }
            }
        }
    }
    
    @ViewBuilder
    private var songsThatMatch: some View {
        if viewModel.songsThatMatchQuery.isNotEmpty {
            Section("Songs") {
                ForEach(viewModel.songsThatMatchQuery) { song in
                    SongCellView(
                        viewModel: SongCellViewModel(
                            song: song,
                            isDetailed: true
                        )
                    )
                }
            }
        }
    }
    
    @ViewBuilder
    private var taggedSongs: some View {
        if viewModel.songsWithTags.isNotEmpty {
            Section("Songs that match tags") {
                ForEach(viewModel.songsWithTags) { song in
                    SongCellView(
                        viewModel: SongCellViewModel(
                            song: song,
                            isDetailed: true
                        )
                    )
                }
            }
        }
    }
    
    @ViewBuilder
    private var albumsThatMatch: some View {
        if viewModel.albumsThatMatchQuery.isNotEmpty {
            Section("Albums") {
                ForEach(viewModel.albumsThatMatchQuery) { album in
                    AlbumCellView(
                        viewModel: AlbumViewModel(
                            album: album
                        )
                    )
                }
            }
        }
    }
    
    @ViewBuilder
    private var artistsThatMatch: some View {
        if viewModel.artistsThatMatchQuery.isNotEmpty {
            Section("Artists") {
                ForEach(viewModel.artistsThatMatchQuery) { artist in
                    ArtistCellView(viewModel: ArtistViewModel(artist: artist))
                }
            }
        }
    }
}

#Preview {
    SearchView()
}
