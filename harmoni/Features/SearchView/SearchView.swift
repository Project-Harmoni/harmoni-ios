//
//  SearchView.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/6/24.
//

import SwiftUI

struct SearchView: View {
    @Environment(\.isAdult) var isAdult
    @EnvironmentObject var nowPlayingManager: NowPlayingManager
    @StateObject var viewModel = SearchViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                if viewModel.searchString.isNotEmpty {
                    taggedSongs
                    songsThatMatch
                    albumsThatMatch
                    artistsThatMatch
                }
                genreTaggedSongs
                moodTaggedSongs
                instrumentsTaggedSongs
                miscTaggedSongs
                advancedSearchSongsThatMatch
                advancedSearchAlbumsThatMatch
                advancedSearchArtistsThatMatch
                latestSongs
            }
            .searchable(
                text: $viewModel.searchString,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: Text("Artists, Songs, Albums, and Tags")
            )
            .refreshable {
                await viewModel.getLatestSongs(force: true)
            }
            .task {
                await viewModel.getLatestSongs()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SearchFilterView(viewModel: viewModel.filterViewModel)
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .overlay(alignment: .topTrailing) {
                                Circle()
                                    .foregroundStyle(
                                        viewModel.filterViewModel.areFiltersApplied
                                        ? Color.primary
                                        : .clear
                                    )
                                    .frame(height: 10)
                            }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Search")
        }
    }
    
    @ViewBuilder
    private func section(from songs: [Song], with title: String) -> some View {
        if songs.isNotEmpty {
            Section(title) {
                ForEach(songs.filter { isAdult || !$0.details.isExplicit }) { song in
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
    private func section(from albums: [AlbumDB], with title: String) -> some View {
        if albums.isNotEmpty {
            Section(title) {
                ForEach(albums.filter { isAdult || !$0.isExplicit }) { album in
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
    private func section(from artists: [ArtistDB], with title: String) -> some View {
        if artists.isNotEmpty {
            Section(title) {
                ForEach(artists) { artist in
                    ArtistCellView(viewModel: ArtistViewModel(artist: artist))
                }
            }
        }
    }
    
    @ViewBuilder
    private func section(from songs: [Song], with tags: [Tag], with title: String) -> some View {
        if songs.isNotEmpty {
            Section {
                ForEach(songs.filter { isAdult || !$0.details.isExplicit }) { song in
                    SongCellView(
                        viewModel: SongCellViewModel(
                            song: song,
                            isDetailed: true
                        )
                    )
                }
            } header: {
                VStack(alignment: .leading) {
                    Text(title)
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(tags) { tag in
                                Button(tag.name, action: {})
                                    .buttonStyle(.bordered)
                                    .disabled(true)
                                    .foregroundStyle(.primary)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var latestSongs: some View {
        section(from: viewModel.latestSongs, with: "Latest")
    }
    
    @ViewBuilder
    private var songsThatMatch: some View {
        section(from: viewModel.songsThatMatchQuery, with: "Songs")
    }
    
    @ViewBuilder
    private var advancedSearchSongsThatMatch: some View {
        section(from: viewModel.advancedSearchSongsThatMatchQuery, with: "Advanced Search Songs")
    }
    
    @ViewBuilder
    private var taggedSongs: some View {
        if viewModel.songsWithTags.isNotEmpty {
            Section {
                ForEach(viewModel.songsWithTags.filter { isAdult || !$0.details.isExplicit }) { song in
                    SongCellView(
                        viewModel: SongCellViewModel(
                            song: song,
                            isDetailed: true
                        )
                    )
                }
            } header: {
                VStack(alignment: .leading) {
                    Text("Songs that match tag")
                    ScrollView(.horizontal) {
                        Button(viewModel.searchString, action: {})
                            .buttonStyle(.bordered)
                            .disabled(true)
                            .foregroundStyle(.primary)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var genreTaggedSongs: some View {
        section(
            from: viewModel.genreSongsWithTags,
            with: viewModel.filterViewModel.genreTagsViewModel.tags,
            with: "Songs with genre tag(s):"
        )
    }
    
    @ViewBuilder
    private var moodTaggedSongs: some View {
        section(
            from: viewModel.moodSongsWithTags,
            with: viewModel.filterViewModel.moodTagsViewModel.tags,
            with: "Songs with mood tag(s):"
        )
    }
    
    @ViewBuilder
    private var instrumentsTaggedSongs: some View {
        section(
            from: viewModel.instrumentsSongsWithTags,
            with: viewModel.filterViewModel.instrumentsTagsViewModel.tags,
            with: "Songs with instrument tag(s):"
        )
    }
    
    @ViewBuilder
    private var miscTaggedSongs: some View {
        section(
            from: viewModel.miscSongsWithTags,
            with: viewModel.filterViewModel.miscTagsViewModel.tags,
            with: "Songs with miscellaneous tag(s):"
        )
    }
    
    @ViewBuilder
    private var albumsThatMatch: some View {
        section(from: viewModel.albumsThatMatchQuery, with: "Albums")
    }
    
    @ViewBuilder
    private var artistsThatMatch: some View {
        section(from: viewModel.artistsThatMatchQuery, with: "Artists")
    }
    
    @ViewBuilder
    private var advancedSearchAlbumsThatMatch: some View {
        section(from: viewModel.advancedSearchAlbumsThatMatchQuery, with: "Advanced Search Albums")
    }
    
    @ViewBuilder
    private var advancedSearchArtistsThatMatch: some View {
        section(from: viewModel.advancedSearchArtistsThatMatchQuery, with: "Advanced Search Artists")
    }
}

#Preview {
    SearchView()
}
