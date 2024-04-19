//
//  TagExplorerView.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/18/24.
//

import SwiftUI

struct TagExplorerView: View {
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var viewModel = TagExplorerViewModel()
    
    var body: some View {
        Group {
            if let tagExplorer = viewModel.tagExplorer {
                List {
                    Section(TagCategory.genres.rawValue) {
                        list(for: tagExplorer.genreTags)
                    }
                    Section(TagCategory.moods.rawValue) {
                        list(for: tagExplorer.moodTags)
                    }
                    Section(TagCategory.instruments.rawValue) {
                        list(for: tagExplorer.instrumentsTags)
                    }
                    Section(TagCategory.miscellaneous.rawValue) {
                        list(for: tagExplorer.miscTags)
                    }
                }
            } else {
                ProgressView("Loading")
            }
        }
        .navigationTitle("Explore Tags")
    }
    
    private func list(for tags: [TagDB]) -> some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ForEach(tags) { tag in
                    Button {
                    } label: {
                        Text(tag.name)
                            .foregroundStyle(
                                colorScheme == .dark
                                ? .white
                                : .black
                            )
                    }
                    .buttonStyle(.bordered)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                    .disabled(true)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 4)
        }
        .scrollIndicators(.never)
        .overlay {
            ZStack {
                HStack {
                    LinearGradient(colors: [gradient, .clear], startPoint: .leading, endPoint: .trailing)
                        .frame(width: 16)
                    Spacer()
                }
                HStack {
                    Spacer()
                    LinearGradient(colors: [.clear, gradient], startPoint: .leading, endPoint: .trailing)
                        .frame(width: 16)
                }
            }
            .allowsHitTesting(false)
        }
    }
    
    private var gradient: Color {
        colorScheme == .dark ? Color(uiColor: .secondarySystemBackground) : .white
    }
}

#Preview {
    TagExplorerView()
}
