//
//  AllTagsViewSheet.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/31/24.
//

import SwiftUI

struct AllTagsViewSheet: View {
    let albumID: Int8?
    let isReadOnly: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tags")
                .font(.title2)
                .bold()
                .padding(.leading)
                .padding(.top, 24)
            List {
                AllTagsView(
                    viewModel: AllTagsViewModel(
                        albumID: albumID,
                        isReadOnly: isReadOnly
                    )
                )
                .environmentObject(UploadStore())
                .listSectionSpacing(0)
            }
            .scrollContentBackground(.hidden)
            .padding(EdgeInsets())
        }
        .presentationDetents([.fraction(0.7)])
        .presentationCornerRadius(24)
        .presentationBackground(.thinMaterial)
        .presentationDragIndicator(.visible)
    }
}
