//
//  ConfirmUploadView.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/25/24.
//

import SwiftUI

struct ConfirmUploadView: View {
    @EnvironmentObject private var uploadStore: UploadStore
    @StateObject var viewModel: ConfirmUploadViewModel = ConfirmUploadViewModel()
    
    var body: some View {
        List {
            Section("Metadata") {
                metadata
            }
            Section("Tags") {
                tags
            }
            Section("Payout Configuration") {
                ForEach($uploadStore.tracks) { track in
                    cell(for: track)
                }
            }
            Section {
                uploadCTA
            }
            .listRowBackground(
                Rectangle().foregroundStyle(.blue)
            )
            
        }
        .navigationTitle("Confirm Upload")
        .alert(
            "Uh oh!",
            isPresented: $viewModel.isError,
            actions: {
                Button("OK", role: .none, action: {})
            }, message: {
                Text("An error occurred uploading. Please try again.")
            }
        )
        .onAppear() {
            viewModel.store = uploadStore
        }
    }
    
    private var metadata: some View {
        Group {
            albumCoverImage
            artistNameField
            albumTitleField
            yearReleasedField
            recordLabelField
            isExplicit
        }
    }
    
    @ViewBuilder
    private var tags: some View {
        Section {
            TagListView(viewModel: uploadStore.genreTagsViewModel)
        } header: {
            Text("Genres")
                .font(.subheadline)
        }
        Section {
            TagListView(viewModel: uploadStore.moodTagsViewModel)
        } header: {
            Text("Moods")
                .font(.subheadline)
        }
        Section {
            TagListView(viewModel: uploadStore.instrumentsTagsViewModel)
        } header: {
            Text("Instruments")
                .font(.subheadline)
        }
        Section {
            TagListView(viewModel: uploadStore.miscTagsViewModel)
        } header: {
            Text("Miscellaneous")
                .font(.subheadline)
        }
    }
    
    @ViewBuilder
    private var albumCoverImage: some View {
        if let image = uploadStore.albumCoverImage {
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
    
    private var artistNameField: some View {
        HStack {
            Text("Artist")
            Spacer()
            Text(uploadStore.artistName)
                .foregroundStyle(.gray)
        }
    }
    
    private var albumTitleField: some View {
        HStack {
            Text("Album title")
            Spacer()
            Text(uploadStore.albumTitle)
                .foregroundStyle(.gray)
        }
    }
    
    private var yearReleasedField: some View {
        HStack {
            Text("Year")
            Spacer()
            Text(uploadStore.yearReleased)
                .foregroundStyle(.gray)
        }
    }
    
    private var recordLabelField: some View {
        HStack {
            Text("Record label")
            Spacer()
            Text(uploadStore.recordLabel)
                .foregroundStyle(.gray)
        }
    }
    
    private var isExplicit: some View {
        HStack {
            Text("Is Explicit?")
            Spacer()
            Text("\(uploadStore.isExplicit ? "Yes" : "No")")
                .foregroundStyle(.gray)
        }
    }
    
    private func cell(for track: Binding<Track>) -> some View {
        EditTrackPayoutView(
            track: track,
            isReadOnly: true
        )
    }
    
    private var uploadCTA: some View {
        HStack {
            Button {
                viewModel.upload()
            } label: {
                HStack {
                    uploadLabel
                    Spacer()
                    Image(systemName: "arrow.up")
                        .bold()
                }
                .foregroundStyle(.white)
            }
            .disabled(isUploading)
        }
    }
    
    @ViewBuilder
    private var uploadLabel: some View {
        if isUploading {
            HStack {
                ProgressView().tint(.white)
                Text("Uploading...").bold()
            }
        } else {
            Text("Upload").bold()
        }
    }
    
    private var isUploading: Bool {
        viewModel.isSaving
    }
}

#Preview {
    ConfirmUploadView()
        .environmentObject(UploadStore())
}
