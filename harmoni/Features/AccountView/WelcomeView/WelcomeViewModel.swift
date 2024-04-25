//
//  WelcomeViewModel.swift
//  harmoni
//
//  Created by Sarah Matthews on 4/11/24.
//

import Foundation
import Supabase

class WelcomeViewModel: ObservableObject {
    @Published var currentUser: User?
    private let user: UserProviding = UserProvider()
    private let database: DBServiceProviding = DBService()
    
    init() {}
    
    func toggleIsNewOff(with completion: @escaping (()->Void)) {
        Task.detached { @MainActor [weak self] in
            do {
                guard let self else { return }
                guard let id = await self.user.currentUserID else { return }
                guard var user = try await self.database.getUser(with: id) else { return }
                user.isNew = false
                try await self.database.upsert(user: user)
                completion()
            } catch {
                dump(error)
            }
            
        }
    }
    
}
