//
//  UploadStore.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/25/24.
//

import PhotosUI
import SwiftUI

class UploadStore: ObservableObject {
    var tracks: [Track] = []
    var albumTitle: String = ""
    var artistName: String = ""
    var isExplicit: Bool = false
    var yearReleased: String = ""
    var recordLabel: String = ""
    var albumCoverItem: PhotosPickerItem?
    var albumCoverImage: Image?
    private let userProvider: UserProviding?
    
    init(userProvider: UserProviding = UserProvider()) {
        self.userProvider = userProvider
    }
    
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

extension UploadStore {
    func name(for track: Track) async -> String? {
        guard let artistID = await userProvider?.currentUserID else { return nil }
        return "\(artistID.uuidString)_\(albumTitle)_\(yearReleased)_\(track.name)_\(track.ordinal)_\(UUID())\(track.fileExtension)"
    }
    
    var albumCoverName: String? {
        get async {
            guard let artistID = await userProvider?.currentUserID else { return nil }
            return "\(artistID.uuidString)_\(albumTitle)_\(yearReleased)_\(UUID())".toJPG
        }
    }
    
    var durationOfTracks: Double? {
        get async {
            do {
                var duration: Double = 0
                for track in tracks {
                    // https://stackoverflow.com/a/33313235
                    let asset = AVURLAsset(url: track.url, options: .none)
                    duration += try await asset.load(.duration).seconds
                }
                return duration
            } catch {
                return nil
            }
        }
    }
}
