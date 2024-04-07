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
            placement: .navigationBarDrawer(displayMode: .always), 
            prompt: Text("Artists, Songs, Albums, and #Tags")
        )
        .refreshable {
            await viewModel.getLatestSongs(force: true)
        }
        .task {
            await viewModel.getLatestSongs()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.isShowingInfoPopover.toggle()
                } label: {
                    Image(systemName: "info.circle")
                }
                .popover(isPresented: $viewModel.isShowingInfoPopover) {
                    Text("Search Tags by prefixing with # sign. For example, #jazz will search for songs tagged with 'jazz'.")
                        .font(.caption)
                        .padding()
                        .presentationCompactAdaptation(.popover)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SearchView()
}
