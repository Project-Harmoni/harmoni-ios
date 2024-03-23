//
//  SongDetailViewModel.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/16/24.
//

import Foundation

class SongDetailViewModel: ObservableObject {
    @Published var isAudioStarted: Bool = false
    @Published var isPlaying: Bool = false
    @Published var fileURL: URL?
}
