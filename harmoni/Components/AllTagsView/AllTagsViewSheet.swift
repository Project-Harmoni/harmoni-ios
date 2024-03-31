//
//  AllTagsViewSheet.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/31/24.
//

import SwiftUI

struct AllTagsViewSheet: View {
    let viewModel: AllTagsViewModel
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            HStack {
                Text("Tags")
                    .font(.title2)
                    .bold()
                    .padding(.leading)
                    .padding(.top, 24)
                Spacer()
            }
            tags
        }
        .presentationDetents([.fraction(fractionHeight)])
        .presentationCornerRadius(24)
        .presentationBackground(.thinMaterial)
        .presentationDragIndicator(.visible)
    }
    
    @ViewBuilder
    private var tags: some View {
        if viewModel.allTagsEmpty {
            Spacer()
            Text("No tags")
            Spacer()
        } else {
            List {
                AllTagsView(
                    viewModel: viewModel
                )
                .environmentObject(UploadStore())
                .listSectionSpacing(0)
            }
            .scrollContentBackground(.hidden)
            .padding(EdgeInsets())
        }
    }
    
    private var fractionHeight: CGFloat {
        viewModel.allTagsEmpty ? 0.25 : 0.7
    }
}

#Preview {
    AllTagsViewSheet(viewModel: AllTagsViewModel())
}
