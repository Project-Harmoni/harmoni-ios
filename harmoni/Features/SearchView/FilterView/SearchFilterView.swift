//
//  SearchFilterView.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/8/24.
//

import SwiftUI

struct SearchFilterView: View {
    @ObservedObject var viewModel: SearchFilterViewModel
    
    var body: some View {
        filters
    }
    
    private var filters: some View {
        List {
            Section("Song") {
                TextField("Title", text: $viewModel.songTitle)
            }
            Section("Album") {
                TextField("Title", text: $viewModel.albumTitle)
            }
            Section("Artist") {
                TextField("Name", text: $viewModel.artistName)
            }
            Section("Tags") {
                AllTagsView(
                    viewModel: viewModel.allTagsViewModel
                )
                .environmentObject(UploadStore())
            }
        }
        .navigationTitle("Advanced Search")
    }
}

#Preview {
    SearchFilterView(
        viewModel: SearchFilterViewModel()
    )
}
