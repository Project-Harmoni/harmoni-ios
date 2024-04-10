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

    @Published var genreTagsViewModel: TagListViewModel
    @Published var moodTagsViewModel: TagListViewModel
    @Published var instrumentsTagsViewModel: TagListViewModel
    @Published var miscTagsViewModel: TagListViewModel
    
    init(
        genreTags: TagListViewModel = .init(category: .genres),
        moodTags: TagListViewModel = .init(category: .moods),
        instrumentTags: TagListViewModel = .init(category: .instruments),
        miscTags: TagListViewModel = .init(category: .miscellaneous),
        albumID: Int8? = nil,
        isReadOnly: Bool = false
    ) {
        self.albumID = albumID
        self.isReadOnly = isReadOnly
        self.genreTagsViewModel = genreTags
        self.moodTagsViewModel = moodTags
        self.instrumentsTagsViewModel = instrumentTags
        self.miscTagsViewModel = miscTags
        
        self.genreTagsViewModel.isReadOnly = isReadOnly
        self.moodTagsViewModel.isReadOnly = isReadOnly
        self.instrumentsTagsViewModel.isReadOnly = isReadOnly
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
