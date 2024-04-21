//
//  Track.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/16/24.
//

import Foundation

/// Represents selected track to upload
struct Track: Identifiable, Hashable, Equatable {
    let id = UUID()
    var serverID: Int8?
    var ordinal: Int = 0
    var url: URL
    var name: String
    var fileExtension: String
    var artistPercentage: CGFloat = 80
    var streamThreshold: Int = 1000
    /// Number of streams to modify in alert textfield
    var numberOfStreamsAlert: Int = 1000
    /// If new lower threshold set, check if payout required
    var isPayoutRequired: Bool = false
    var isFreeToStream: Bool = false
    var payoutType: TrackPayoutType = .proportional
}
