//
//  RecentlyPlayedView.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/25/24.
//

import SwiftUI

struct RecentlyPlayedView: View {
    @StateObject private var viewModel = RecentlyPlayedViewModel()
    
    var body: some View {
        recentlyPlayedContainer
            .navigationTitle("Recently Played")
    }
    
    @ViewBuilder
    private var recentlyPlayedContainer: some View {
        if viewModel.isLoading {
            ProgressView("Loading")
        } else if viewModel.recentlyPlayed.isEmpty {
            Text("Your recently played music will live here")
        } else {
            recentlyPlayed
        }
    }
    
    private var recentlyPlayed: some View {
        List {
            ForEach(viewModel.recentlyPlayed) { song in
                SongCellView(
                    viewModel: .init(
                        song: song,
                        queue: viewModel.recentlyPlayed,
                        isDetailed: true
                    )
                )
            }
        }
    }
}
