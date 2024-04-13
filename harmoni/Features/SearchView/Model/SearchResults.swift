//
//  SearchResults.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/7/24.
//

import Foundation

struct SearchResults {
    /// Songs that match search query
    var songs: [Song]
    /// Songs that are associated with tag(s)
    var songsWithTags: [Song] = []
    /// Songs that are associated with genre tag(s)
    var genreTaggedSongs: [Song] = []
    /// Songs that are associated with mood tag(s)
    var moodTaggedSongs: [Song] = []
    /// Songs that are associated with instrument tag(s)
    var instrumentTaggedSongs: [Song] = []
    /// Songs that are associated with miscellaneous tag(s)
    var miscTaggedSongs: [Song] = []
    /// Albums that match search query
    var albums: [AlbumDB]
    /// Artists that match search query
    var artists: [ArtistDB]
}
