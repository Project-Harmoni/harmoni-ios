//
//  AllTagsView.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/30/24.
//

import SwiftUI

class AllTagsViewModel: ObservableObject {
    let isReadOnly: Bool
    let database: DBServiceProviding = DBService()
    let albumID: Int8?

    @Published var genreTagsViewModel = TagListViewModel(
        tags: [],
        category: .genres
    )
    @Published var moodTagsViewModel = TagListViewModel(
        tags: [],
        category: .moods
    )
    @Published var instrumentsTagsViewModel = TagListViewModel(
        tags: [],
        category: .instruments
    )
    @Published var miscTagsViewModel = TagListViewModel(
        tags: [],
        category: .miscellaneous
    )
    
    init(
        genreTags: [Tag] = [],
        moodTags: [Tag] = [],
        instrumentTags: [Tag] = [],
        miscTags: [Tag] = [],
        albumID: Int8? = nil,
        isReadOnly: Bool = false
    ) {
        self.albumID = albumID
        self.isReadOnly = isReadOnly
        self.genreTagsViewModel.tags = genreTags
        self.genreTagsViewModel.isReadOnly = isReadOnly
        self.moodTagsViewModel.tags = moodTags
        self.moodTagsViewModel.isReadOnly = isReadOnly
        self.instrumentsTagsViewModel.tags = instrumentTags
        self.instrumentsTagsViewModel.isReadOnly = isReadOnly
        self.miscTagsViewModel.tags = miscTags
        self.miscTagsViewModel.isReadOnly = isReadOnly
    }
    
    var allTagsEmpty: Bool {
        genreTagsViewModel.tags.isEmpty &&
        moodTagsViewModel.tags.isEmpty &&
        instrumentsTagsViewModel.tags.isEmpty &&
        miscTagsViewModel.tags.isEmpty
    }
    
    @MainActor
    func getTags() async {
        guard let albumID, allTagsEmpty else { return }
        do {
            let tags = try await database.tagsOnAlbum(with: albumID)
            genreTagsViewModel.tags = tags.filter { $0.category == .genres }
            moodTagsViewModel.tags = tags.filter { $0.category == .moods }
            instrumentsTagsViewModel.tags = tags.filter { $0.category == .instruments }
            miscTagsViewModel.tags = tags.filter { $0.category == .miscellaneous }
        } catch {
            dump(error)
        }
    }
}

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
    AllTagsView()
}
