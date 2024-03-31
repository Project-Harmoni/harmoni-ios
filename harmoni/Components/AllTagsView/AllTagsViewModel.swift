//
//  AllTagsViewModel.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/31/24.
//

import Foundation

class AllTagsViewModel: ObservableObject {
    let isReadOnly: Bool
    let database: DBServiceProviding = DBService()
    let albumID: Int8?
    var tags: [Tag] = []

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
        self.genreTagsViewModel.configure(with: genreTags, isReadOnly: isReadOnly)
        self.moodTagsViewModel.configure(with: moodTags, isReadOnly: isReadOnly)
        self.instrumentsTagsViewModel.configure(with: instrumentTags, isReadOnly: isReadOnly)
        self.miscTagsViewModel.configure(with: miscTags, isReadOnly: isReadOnly)
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
            tags = try await database.tagsOnAlbum(with: albumID)
            genreTagsViewModel.tags = tags.genres
            moodTagsViewModel.tags = tags.moods
            instrumentsTagsViewModel.tags = tags.instruments
            miscTagsViewModel.tags = tags.misc
        } catch {
            dump(error)
        }
    }
}
