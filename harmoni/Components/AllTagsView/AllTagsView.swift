//
//  AllTagsView.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/30/24.
//

import SwiftUI

struct AllTagsView: View {
    @EnvironmentObject private var uploadStore: UploadStore
    @ObservedObject var viewModel: AllTagsViewModel = AllTagsViewModel()
    
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
        .task {
            await viewModel.getTags()
        }
    }
}

#Preview {
    NavigationStack {
        List {
            AllTagsView()
                .navigationTitle("Tags")
        }
        .listSectionSpacing(0)
    }
}
