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
    var platformConstants: PlatformConstants = PlatformConstants()
    
    init(tracks: [Track]) {
        self.tracks = tracks
    }
    
    func editStreamsUntilPayout() {
        for track in selectedTracks {
            if let index = tracks.firstIndex(where: { $0.id == track }) {
                var threshold = Int(streamThreshold) ?? 1000
                threshold = threshold < minimium ? minimium : threshold
                let currentStreamThreshold = tracks[index].streamThreshold
                tracks[index].streamThreshold = threshold
                tracks[index].numberOfStreamsAlert = threshold
                tracks[index].isPayoutRequired = threshold < currentStreamThreshold
            }
        }
        streamThreshold = ""
    }
    
    func editArtistPercentage() {
        for track in selectedTracks {
            if let index = tracks.firstIndex(where: { $0.id == track }) {
                var percentage = CGFloat((artistPercentage as NSString).floatValue)
                percentage = percentage > 100 ? 100 : percentage
                percentage = percentage < 0 ? 0 : percentage
                tracks[index].artistPercentage = percentage
            }
        }
        artistPercentage = ""
    }
    
    func editFreeToStream() {
        for track in selectedTracks {
            if let index = tracks.firstIndex(where: { $0.id == track }) {
                tracks[index].isFreeToStream = true
            }
        }
    }
    
    func editPaidToStream() {
        for track in selectedTracks {
            if let index = tracks.firstIndex(where: { $0.id == track }) {
                tracks[index].isFreeToStream = false
            }
        }
    }
    
    func editProportionalPayout() {
        for track in selectedTracks {
            if let index = tracks.firstIndex(where: { $0.id == track }) {
                tracks[index].payoutType = .proportional
            }
        }
    }
    
    func editJackpotPayout() {
        for track in selectedTracks {
            if let index = tracks.firstIndex(where: { $0.id == track }) {
                tracks[index].payoutType = .jackpot
            }
        }
    }
    
    private var minimium: Int {
        platformConstants.minimumPaymentThreshold
    }
}
