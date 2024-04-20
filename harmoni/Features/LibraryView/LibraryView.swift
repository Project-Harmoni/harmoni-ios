//
//  LibraryView.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/14/24.
//

import SwiftUI

struct LibraryView: View {
    @Environment(\.colorScheme) private var colorScheme
    @StateObject var viewModel = LibraryViewModel()
    @State private var size: CGSize = .zero
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    var body: some View {
        libraryContainer
    }
    
    @ViewBuilder
    private var libraryContainer: some View {
        if viewModel.isLoading {
            ProgressView("Loading")
        } else if viewModel.media.isEmpty {
            Text("Your library is empty")
        } else {
            library
        }
    }
    private var library: some View {
        ScrollView {
            VStack(alignment: .leading) {
                librarySections
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
    
    private var librarySections: some View {
        VStack(alignment: .leading) {
            ForEach(LibrarySection.allCases) { section in
                Divider()
                NavigationLink {
                    switch section {
                    case .artists: LibraryArtistsView()
                    case .favorites: FavoritesView()
                    }
                } label: {
                    HStack {
                        Text(section.rawValue)
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                    .font(.title3)
                }
                .padding(.vertical, 4)
            }
            Divider()
        }
        .padding(.bottom, 24)
    }
}

#Preview {
    LibraryView()
}
