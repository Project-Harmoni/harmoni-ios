//
//  ChooseRoleViewModel.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/13/24.
//

import SwiftUI
import Supabase

class ChooseRoleViewModel: ObservableObject {
    @Published var role: SignUpRole = .listener
    @Published var birthday: Date = .now
    @Published var errorMessage: AuthFlowError?
    @Published var isError: Bool = false
    @Published var isCompleting: Bool = false
    var onDismissTapped: (() -> Void)?
    var onSignUp: (() -> Void)?
    var onCompletion: (() -> Void)
    private let database: DBServiceProviding = DBService()
    
    init(
        birthday: Binding<Date>,
        onDismissTapped: (() -> Void)? = nil,
        onSignUp: (() -> Void)? = nil,
        onCompletion: @escaping (() -> Void)
    ) {
        self.birthday = birthday.wrappedValue
        self.onSignUp = onSignUp
        self.onDismissTapped = onDismissTapped
        self.onCompletion = onCompletion
    }
    
    func completeRegistration() {
        Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                self.isCompleting = true
                guard let user = await AuthManager.shared.currentUser else {
                    return handleError(message: "Unable to authorize. Please try again.")
                }
                try await self.updateDatabase(with: user)
                errorMessage = nil
                self.isCompleting = false
                await AuthManager.shared.checkRegistration()
                onCompletion()
            } catch {
                dump(error)
                self.handleError(message: error.localizedDescription)
            }
        }
    }
    
    func signUp() {
        Task { @MainActor [weak self] in
            self?.isCompleting = true
            self?.onSignUp?()
        }
    }
    
    private func handleError(message: String) {
        errorMessage = AuthFlowError.custom(error: message)
        isCompleting = false
        isError = true
    }
    
    private func getDBUser(from user: User) -> UserDB {
        var userDB = user.toUserDB()
        userDB.birthday = birthday.yyyyMMdd
        userDB.type = role.rawValue
        return userDB
    }
    
    private func updateDatabase(with user: User) async throws {
        let userDB = getDBUser(from: user)
        try await database.upsert(user: userDB)
        
        switch role {
        case .listener:
            let listener = ListenerDB(from: userDB)
            try await database.upsert(listener: listener)
        case .artist:
            let artist = ArtistDB(from: userDB)
            try await database.upsert(artist: artist)
        }
    }
}
