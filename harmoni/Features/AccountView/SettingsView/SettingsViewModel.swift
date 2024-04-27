//
//  SettingsViewModel.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/21/24.
//

import SwiftUI

enum SettingsError: Error {
    case unableToDeleteAccount
}

class SettingsViewModel: ObservableObject {
    @AppStorage("isAdminRequested") var isAdminRequested: Bool = false
    @Published var isDisplayingDeleteAccountAlert: Bool = false
    @Published var isDisplayingAdminRequest: Bool = false
    @Published var isDisplayingRequestSent: Bool = false
    var logoutAction: (() async -> Void)? = nil
    var currentUserID: String?
    let userProvider: UserProviding = UserProvider()
    let database: DBServiceProviding = DBService()
    let edge: EdgeProviding = EdgeService()
    let storage: StorageProviding = StorageService()
    
    init(logoutAction: @escaping () async -> Void) {
        self.logoutAction = logoutAction
        
        Task { @MainActor [weak self] in
            guard let self else { return }
            self.currentUserID = await self.userProvider.currentUserID?.uuidString
        }
    }
    
    func deleteAccount() async throws {
        guard let currentUserID else { return }
        try await self.database.deleteUser(with: currentUserID)
        try await self.storage.deleteAccountFiles(for: currentUserID)
    }
}
