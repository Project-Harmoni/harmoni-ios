//
//  LibraryView.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/14/24.
//

import SwiftUI

@MainActor class LibraryViewModel: ObservableObject {
    @Published var media: [LibraryItem] = []
    @Published var isError: Bool = false
    let database: DBServiceProviding = DBService()
    let userProvider: UserProviding = UserProvider()
    
    func getLibrary() {
        Task { [weak self] in
            guard let self else { return }
            do {
                guard let currentUserID = await userProvider.currentUserID else { return }
                media = try await database.getLibrary(for: currentUserID.uuidString)
            } catch {
                dump(error)
                isError.toggle()
            }
        }
    }
    
    var sortedMedia: [LibraryItem] {
        media
            .sorted {
                guard let firstDate = $0.date, let secondDate = $1.date else { return true }
                return firstDate > secondDate
            }
    }
}

struct LibraryMediaCellView: View {
    @Environment(\.colorScheme) private var colorScheme
    let song: Song
    let size: CGSize
    
    var body: some View {
        VStack(alignment: .leading) {
            CoverArtView(
                imagePath: song.details.coverImagePath,
                placeholderName: "music.note",
                size: size.width / 2.35,
                cornerRadius: 8
            )
            if let albumName = song.details.albumName {
                Text(albumName)
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
            }
            Text(song.artistName)
                .foregroundStyle(.gray)
        }
    }
}

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
