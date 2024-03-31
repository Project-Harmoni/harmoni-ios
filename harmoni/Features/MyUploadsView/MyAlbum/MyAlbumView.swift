//
//  MyAlbumView.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/29/24.
//

import SwiftUI

class MyAlbumViewModel: ObservableObject {
    let database: DBServiceProviding = DBService()
    let album: AlbumDB
    @MainActor @Published var songs: [SongDB] = []
    @MainActor @Published var selectedSongs: Set<SongDB.ID> = []
    @MainActor @Published var isPresentingEdit: Bool = false
    @MainActor @Published var isLoading: Bool = false
    @MainActor @Published var isError: Bool = false
    
    init(album: AlbumDB) {
        self.album = album
    }
    
    @MainActor
    func getSongs() async {
        guard songs.isEmpty else { return }
        do {
            guard let albumID = album.id else { return isError.toggle() }
            isLoading.toggle()
            songs = try await database.songs(on: albumID)
            isLoading.toggle()
        } catch {
            dump(error)
            isError.toggle()
            isLoading.toggle()
        }
    }
    
    var albumTitle: String? {
        album.name
    }
    
    var yearReleased: String? {
        album.yearReleased
    }
    
    var totalTracks: Int {
        album.totalTracks
    }
    
    var totalTracksLabel: String {
        plural(totalTracks, "song")
    }
    
    var duration: String? {
        guard let albumDuration = album.duration else { return nil }
        let seconds = modf(albumDuration).0
        let milliseconds = modf(albumDuration).1
        let duration = Duration.seconds(seconds) + Duration.milliseconds(milliseconds)
        return duration.formatted(.units(width: .wide))
    }
    
    var totalTracksDurationLabel: String? {
        [totalTracksLabel, duration]
            .compactMap { $0 }
            .joined(separator: ", ")
    }
    
    var recordLabel: String? {
        album.recordLabel
    }
}

struct MyAlbumView: View {
    @ObservedObject var viewModel: MyAlbumViewModel
    
    var body: some View {
        albumContainer
            .task {
                await viewModel.getSongs()
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
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.isPresentingEdit.toggle()
                } label: {
                    Text("Edit")
                }
            }
        }
        .sheet(isPresented: $viewModel.isPresentingEdit) {
            NavigationStack {
                UploadView(
                    viewModel: UploadViewModel(
                        album: .init(artistID: "", totalTracks: 0),
                        songs: [],
                        tags: []
                    )
                )
                .navigationBarTitleDisplayMode(.inline)
            }
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
        MyAlbumView(viewModel: MyAlbumViewModel(album: AlbumDB(id: 0, name: "Test Album", artistID: "", coverImagePath: "", yearReleased: "2024", totalTracks: 10, recordLabel: "Record Label", duration: 50.46, createdAt: nil)))
    }
}
