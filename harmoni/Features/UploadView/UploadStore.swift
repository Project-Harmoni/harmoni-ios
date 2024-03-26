//
//  UploadStore.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/25/24.
//

import SwiftUI

class UploadStore: ObservableObject {
    var tracks: [Track] = []
    var albumTitle: String = ""
    var artistName: String = ""
    var isExplicit: Bool = false
    var yearReleased: String = ""
    var recordLabel: String = ""
    var albumCoverImage: Image?
    
    // Tags
    var genreTagsViewModel = TagListViewModel(
        tags: [],
        category: .genres,
        isReadOnly: true
    )
    var moodTagsViewModel = TagListViewModel(
        tags: [],
        category: .moods,
        isReadOnly: true
    )
    var instrumentsTagsViewModel = TagListViewModel(
        tags: [],
        category: .instruments,
        isReadOnly: true
    )
    var miscTagsViewModel = TagListViewModel(
        tags: [],
        category: .miscellaneous,
        isReadOnly: true
    )
}
