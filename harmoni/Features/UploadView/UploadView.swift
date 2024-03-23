//
//  UploadView.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/15/24.
//

import PhotosUI
import SwiftUI
import Supabase

struct UploadView: View {
    @Environment(\.colorScheme) private var colorScheme
    @StateObject var viewModel = UploadViewModel()
    
    var body: some View {
        form
            .fileImporter(
                isPresented: $viewModel.isShowingFileImporter,
                allowedContentTypes: [.audio],
                allowsMultipleSelection: true
            ) { result in
                switch result {
                case .success(let files): viewModel.handle(files)
                case .failure(let failure): viewModel.handle(failure)
                }
            }
    }
    
    private var form: some View {
        Form {
            Section("Tracks") {
                trackList
                selectTracksButton
            }
            Section("Cover art") {
                albumCoverImage
                albumCoverPicker
            }
            Section("Metadata") {
                artistNameField
                albumTitleField
                yearReleasedField
                recordLabelField
                isExplicit
            }
            Section("Tags") {
                tags
            }
            Section {
                continueToPayout
            }
        }
        .navigationTitle("Upload")
        .alert(
            "Edit Track Name",
            isPresented: $viewModel.isShowingEditTrackNameAlert
        ) {
            TextField("New name", text: $viewModel.editedTrackName)
            Button("Cancel", role: .cancel, action: {})
            Button("Save", role: .none, action: {
                if let track = viewModel.selectedTrack {
                    viewModel.update(track)
                }
            })
        } message: {
            if let selectedTrack = viewModel.selectedTrack {
                Text("Enter new name for track '\(selectedTrack.name)'")
            } else {
                Text("Enter new name for track")
            }
        }
    }
    
    private var artistNameField: some View {
        HStack {
            TextField("Artist name", text: $viewModel.artistName)
                .disabled(!viewModel.currentArtistName.isEmpty)
            if viewModel.currentArtistName.isEmpty {
                Spacer()
                Button {
                    viewModel.isShowingNamePopover.toggle()
                } label: {
                    Image(systemName: "info.circle")
                }
                .popover(isPresented: $viewModel.isShowingNamePopover) {
                    Text("This will set your artist name globally.")
                        .font(.caption)
                        .padding()
                        .presentationCompactAdaptation(.popover)
                }
            }
        }
    }
    
    private var albumTitleField: some View {
        TextField("Album title", text: $viewModel.albumTitle)
    }
    
    private var genreField: some View {
        TextField("Genre", text: $viewModel.genre)
    }
    
    private var yearReleasedField: some View {
        TextField("Year Released", text: $viewModel.yearReleased.max(4))
            .keyboardType(.numberPad)
    }
    
    private var recordLabelField: some View {
        TextField("Record Label", text: $viewModel.recordLabel)
    }
    
    private var isExplicit: some View {
        Toggle("Contains explicit material (18+)", isOn: $viewModel.isExplicit)
    }
    
    private var selectTracksButton: some View {
        Button(isTrackChosen ? "Select different track(s)" : "Select track(s)") {
            viewModel.isShowingFileImporter.toggle()
        }
    }
    
    private var trackList: some View {
        ForEach(viewModel.tracks) { track in
            HStack {
                title(for: track)
                Spacer()
                dragHandler
            }
        }
        .onMove{ from, to in
            viewModel.moveTrack(from: from, to: to)
        }
        .onDelete { indexSet in
            guard viewModel.tracks.indices.contains(indexSet) else { return }
            guard let index = indexSet.first else { return }
            let track = viewModel.tracks[index]
            viewModel.remove(track.url)
        }
    }
    
    @ViewBuilder
    private func title(for track: Track) -> some View {
        Group {
            Text(track.name) +
            Text(track.fileExtension)
                .foregroundStyle(.gray)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            viewModel.selectedTrack = track
            viewModel.isShowingEditTrackNameAlert.toggle()
        }
    }
    
    private var dragHandler: some View {
        Image(systemName: "line.3.horizontal")
            .foregroundStyle(.gray.opacity(0.5))
    }
    
    private var albumCoverPicker: some View {
        PhotosPicker(
            isAlbumCoverChosen ? "Select different album cover" : "Select album cover",
            selection: $viewModel.albumCoverItem,
            matching: .images,
            photoLibrary: .shared()
        )
    }
    
    @ViewBuilder
    private var albumCoverImage: some View {
        if let image = viewModel.albumCoverImage {
            Rectangle()
                .foregroundStyle(.clear)
                .aspectRatio(1, contentMode: .fill)
                .overlay(
                    image
                        .resizable()
                        .scaledToFill()
                )
                .frame(width: 250, height: 250)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
    
    @ViewBuilder
    private var tags: some View {
        Section {
            TagListView(viewModel: viewModel.genreTagsViewModel)
        } header: {
            Text("Genres")
                .font(.subheadline)
        }
        Section {
            TagListView(viewModel: viewModel.moodTagsViewModel)
        } header: {
            Text("Moods")
                .font(.subheadline)
        }
        Section {
            TagListView(viewModel: viewModel.instrumentsTagsViewModel)
        } header: {
            Text("Instruments")
                .font(.subheadline)
        }
        Section {
            TagListView(viewModel: viewModel.miscTagsViewModel)
        } header: {
            Text("Miscellaneous")
                .font(.subheadline)
        }
    }
    
    private var continueToPayout: some View {
        NavigationLink("Payout Configuration") {
            EditPayoutView(
                viewModel: viewModel.payoutViewModel
            )
        }
    }
    
    private var isTrackChosen: Bool {
        !viewModel.tracks.isEmpty
    }
    
    private var isAlbumCoverChosen: Bool {
        viewModel.albumCoverImage != nil
    }
}

#Preview {
    let vm = UploadViewModel()
    vm.tracks = [
        Track(
            url: URL(string: "www.apple.com")!,
            name: "Test",
            fileExtension: ".mp3"
        ),
        Track(
            url: URL(string: "www.apple.com")!,
            name: "Test2",
            fileExtension: ".mp3"
        ),
        Track(
            url: URL(string: "www.apple.com")!,
            name: "Test3",
            fileExtension: ".mp3"
        ),
        Track(
            url: URL(string: "www.apple.com")!,
            name: "Test4",
            fileExtension: ".mp3"
        )
    ]
    return NavigationStack {
        UploadView(viewModel: vm)
    }
}
