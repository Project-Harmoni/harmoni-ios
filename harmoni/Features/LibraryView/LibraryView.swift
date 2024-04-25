//
//  LibraryView.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/14/24.
//

import SwiftUI

struct LibraryView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.container) private var container
    @StateObject var viewModel = LibraryViewModel()
    @State private var size: CGSize = .zero
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    var body: some View {
        libraryContainer
            .onAppear() {
                viewModel.getLibrary()
            }
    }
    
    @ViewBuilder
    private var libraryContainer: some View {
        library
    }
    private var library: some View {
            VStack(alignment: .leading) {
                librarySections
                if viewModel.media.isEmpty {
                    Spacer()
                    VStack(spacing: 26) {
                        Image(systemName: "music.note")
                            .resizable()
                            .aspectRatio(2/3, contentMode: .fit)
                            .foregroundStyle(.gray.secondary)
                            .frame(height: 98)
                        HStack {
                            Spacer()
                            VStack(spacing: 16) {
                                Text("Add Music to Your Library")
                                    .font(.title3)
                                    .foregroundStyle(.gray)
                                Button {
                                    container.selectedTab = 2
                                } label: {
                                    HStack {
                                        Spacer()
                                        Text("Browse Music")
                                            .bold()
                                        Spacer()
                                    }
                                    .frame(height: 42)
                                    .background(.regularMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 25))
                                    .padding(.horizontal, 45)
                                }

                            }
                            Spacer()
                        }
                    }
                    Spacer()
                } else {
                    Text("Recently Added")
                        .font(.title3)
                        .bold()
                    ScrollView {
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
                Spacer()
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
