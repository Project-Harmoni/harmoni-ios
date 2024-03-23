//
//  EditPayoutViewModel.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/20/24.
//

import Foundation

class EditPayoutViewModel: ObservableObject {
    @Published var tracks: [Track]
    @Published var selectedTracks: Set<UUID> = []
    @Published var isSelectingAll: Bool = true
    @Published var streamThreshold: String = ""
    @Published var isShowingEditStreamAlert: Bool = false
    @Published var artistPercentage: String = ""
    @Published var isShowingEditPercentageAlert: Bool = false
    
    lazy var trackPayoutViewModels: [EditTrackPayoutViewModel] = {
        tracks.map { EditTrackPayoutViewModel(track: $0) }
    }()
    
    init(tracks: [Track]) {
        self.tracks = tracks
    }
    
    func editStreamsUntilPayout() {
        for track in selectedTracks {
            if let viewModel = trackPayoutViewModels.first(where: { $0.track.id == track }) {
                var threshold = Int(streamThreshold) ?? 1000
                threshold = threshold < 0 ? 0 : threshold
                viewModel.track.streamThreshold = threshold
            }
        }
        streamThreshold = ""
    }
    
    func editArtistPercentage() {
        for track in selectedTracks {
            if let viewModel = trackPayoutViewModels.first(where: { $0.track.id == track }) {
                var percentage = CGFloat((artistPercentage as NSString).floatValue)
                percentage = percentage > 100 ? 100 : percentage
                percentage = percentage < 0 ? 0 : percentage
                viewModel.track.artistPercentage = percentage
            }
        }
        artistPercentage = ""
    }
    
    func editFreeToStream() {
        for track in selectedTracks {
            if let viewModel = trackPayoutViewModels.first(where: { $0.track.id == track }) {
                viewModel.track.isFreeToStream = true
            }
        }
    }
    
    func editPaidToStream() {
        for track in selectedTracks {
            if let viewModel = trackPayoutViewModels.first(where: { $0.track.id == track }) {
                viewModel.track.isFreeToStream = false
            }
        }
    }
    
    func editProportionalPayout() {
        for track in selectedTracks {
            if let viewModel = trackPayoutViewModels.first(where: { $0.track.id == track }) {
                viewModel.track.payoutType = .proportional
            }
        }
    }
    
    func editJackpotPayout() {
        for track in selectedTracks {
            if let viewModel = trackPayoutViewModels.first(where: { $0.track.id == track }) {
                viewModel.track.payoutType = .jackpot
            }
        }
    }
}
