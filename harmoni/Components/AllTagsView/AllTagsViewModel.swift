//
//  AllTagsViewModel.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/31/24.
//

import Foundation

class AllTagsViewModel: ObservableObject {
    let database: DBServiceProviding = DBService()
    let albumID: Int?
    var isReadOnly: Bool
    var tags: [Tag] = []

    @Published var genreTagsViewModel: TagListViewModel
    @Published var moodTagsViewModel: TagListViewModel
    @Published var instrumentsTagsViewModel: TagListViewModel
    @Published var miscTagsViewModel: TagListViewModel
    
    init(
        genreViewModel: TagListViewModel = .init(category: .genres),
        moodViewModel: TagListViewModel = .init(category: .moods),
        instrumentViewModel: TagListViewModel = .init(category: .instruments),
        miscViewModel: TagListViewModel = .init(category: .miscellaneous),
        albumID: Int? = nil,
        isReadOnly: Bool = false,
        isEditing: Bool = false,
        isAdmin: Bool = false
    ) {
        self.albumID = albumID
        self.isReadOnly = isReadOnly
        self.genreTagsViewModel = genreViewModel
        self.moodTagsViewModel = moodViewModel
        self.instrumentsTagsViewModel = instrumentViewModel
        self.miscTagsViewModel = miscViewModel
        
        for tagViewModel in tagViewModels {
            tagViewModel.isReadOnly = isReadOnly
            tagViewModel.isEditing = isEditing
            tagViewModel.isAdmin = isAdmin
        }
    }
    
    var allTagsEmpty: Bool {
        genreTagsViewModel.tags.isEmpty &&
        moodTagsViewModel.tags.isEmpty &&
        instrumentsTagsViewModel.tags.isEmpty &&
        miscTagsViewModel.tags.isEmpty
    }
    
    var tagViewModels: [TagListViewModel] {
        [
            genreTagsViewModel,
            moodTagsViewModel,
            instrumentsTagsViewModel,
            miscTagsViewModel
        ]
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
