//
//  AccountViewRouter.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/27/24.
//

import SwiftUI

enum AccountViewPath {
    case uploader, myUploads, albums, tags
}

class AccountViewRouter: ObservableObject {
    @Published var path = NavigationPath()
    
    func popToRoot() {
        path = NavigationPath()
    }
}
