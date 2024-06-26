//
//  AllTagsView.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/30/24.
//

import SwiftUI

struct AllTagsView: View {
    @EnvironmentObject private var uploadStore: UploadStore
    @ObservedObject var viewModel: AllTagsViewModel
    
    var body: some View {
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
        .onAppear() {
            uploadStore.genreTagsViewModel = viewModel.genreTagsViewModel
            uploadStore.moodTagsViewModel = viewModel.moodTagsViewModel
            uploadStore.instrumentsTagsViewModel = viewModel.instrumentsTagsViewModel
            uploadStore.miscTagsViewModel = viewModel.miscTagsViewModel
        }
        .task {
            await viewModel.getTags()
        }
    }
}
