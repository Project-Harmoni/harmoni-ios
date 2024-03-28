//
//  MyUploadsView.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/27/24.
//

import SwiftUI

struct MyUploadsView: View {
    @EnvironmentObject var router: AccountViewRouter
    var body: some View {
        NavigationLink("Albums", value: AccountViewPath.albums)
        NavigationLink("Tags", value: AccountViewPath.tags)
        Button {
            router.popToRoot()
        } label: {
            Text("dismiss")
        }
    }
}

#Preview {
    MyUploadsView()
}
