//
//  SearchView.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/6/24.
//

import SwiftUI

struct SearchView: View {
    @StateObject var viewModel = SearchViewModel()
    var body: some View {
        List {
            Section("Latest") {
                ForEach(viewModel.latestSongs) { song in
                    SongCellView(
                        viewModel: SongCellViewModel(
                            song: song,
                            isDetailed: true
                        )
                    )
                }
            }
        }
        .searchable(
            text: $viewModel.searchString,
            placement: .navigationBarDrawer(displayMode: .always)
        )
        .refreshable {
            await viewModel.getLatestSongs(force: true)
        }
        .task {
            await viewModel.getLatestSongs()
        }
    }
}

#Preview {
    SearchView()
}
