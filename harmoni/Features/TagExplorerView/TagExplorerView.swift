//
//  TagExplorerView.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/18/24.
//

import SwiftUI

struct TagExplorerView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.isAdmin) private var isAdmin
    @StateObject private var viewModel = TagExplorerViewModel()
    @State private var isDisplayingEditTagAlert: Bool = false
    @State private var isDisplayingDeleteTagAlert: Bool = false
    
    var body: some View {
        Group {
            if let tagExplorer = viewModel.tagExplorer {
                List {
                    AllTagsView(
                        viewModel: .init(
                            genreViewModel: .init(tags: tagExplorer.genres, category: .genres, isAdmin: isAdmin),
                            moodViewModel: .init(tags: tagExplorer.moods, category: .moods, isAdmin: isAdmin),
                            instrumentViewModel: .init(tags: tagExplorer.instruments, category: .instruments, isAdmin: isAdmin),
                            miscViewModel: .init(tags: tagExplorer.misc, category: .miscellaneous, isAdmin: isAdmin),
                            albumID: nil,
                            isReadOnly: !isAdmin,
                            isEditing: isAdmin,
                            isAdmin: isAdmin
                        )
                    )
                    .environmentObject(UploadStore())
                }
            } else {
                ProgressView("Loading")
            }
        }
        .navigationTitle("Explore Tags")
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

#Preview {
    TagExplorerView()
}
