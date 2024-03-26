//
//  ConfirmUploadView.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/25/24.
//

import SwiftUI

class ConfirmUploadViewModel: ObservableObject {
    @Published var isSaving: Bool = false
}

struct ConfirmUploadView: View {
    @EnvironmentObject var uploadStore: UploadStore
    @StateObject var viewModel: ConfirmUploadViewModel = ConfirmUploadViewModel()
    
    var body: some View {
        List {
            Section("Metadata") {
                metadata
            }
            Section("Payout Configuration") {
                ForEach($uploadStore.tracks) { track in
                    cell(for: track)
                }
            }
            Section("Confirm") {
                Button {
                    
                } label: {
                    Text("Upload")
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .navigationTitle("Confirm Upload")
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
}

#Preview {
    ConfirmUploadView()
}
