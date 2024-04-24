//
//  AuthViewModel.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/13/24.
//

import Combine
import Foundation

@MainActor class AuthViewModel: ObservableObject {
    @Published var showSignUp: Bool = false
    @Published var showLogIn: Bool = false
    /// Registered users must supply birthday and role
    @Published var isRegistrationIncomplete: Bool = false
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        AuthManager.shared.$isRegistrationComplete
            .receive(on: DispatchQueue.main)
            .sink { @MainActor [weak self] in
                guard let isRegistrationComplete = $0 else { return }
                self?.showLogIn = false
                self?.showSignUp = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    self?.isRegistrationIncomplete = !isRegistrationComplete
                }
            }
            .store(in: &cancellables)
    }
}
