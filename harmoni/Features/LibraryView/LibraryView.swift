//
//  LibraryView.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/14/24.
//

import SwiftUI

struct LibraryView: View {
    @StateObject var viewModel = LibraryViewModel()
    @State private var size: CGSize = .zero
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    var body: some View {
        Group {
            if viewModel.media.isEmpty {
                Text("Your library is empty")
            } else {
                library
            }
        }
        .onAppear() {
            viewModel.getLibrary()
        }
    }
    
    private var library: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Recently Added")
                    .font(.title3)
                    .bold()
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(viewModel.sortedMedia) { item in
                        if let song = item.songs.first {
                            NavigationLink {
                                LibraryAlbumView(viewModel: .init(item: item))
                            } label: {
                                LibraryMediaCellView(song: song, size: size)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .readSize {
            size = $0
        }
    }
}

#Preview {
    LibraryView()
}
