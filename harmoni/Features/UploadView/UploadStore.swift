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
}
