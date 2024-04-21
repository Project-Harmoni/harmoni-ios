//
//  EdgeService.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/21/24.
//

import Foundation

protocol EdgeProviding {
    func createWallet(request: CreateWalletRequest) async throws -> CreateWalletResponse?
    func deleteUser(request: DeleteUserRequest) async throws -> DeleteUserResponse?
    func initiateSongPayout(request: InitiateSongPayoutRequest) async throws -> InitiateSongPayoutResponse?
    func playSong(request: PlaySongRequest) async throws -> PlaySongResponse?
    func purchaseTokens(request: PurchaseTokensRequest) async throws -> PurchaseTokensResponse?
}

struct EdgeService: EdgeProviding {
    func createWallet(request: CreateWalletRequest) async throws -> CreateWalletResponse? {
        try await Supabase.shared.client.functions.createWallet(request: request)
    }
    
    func deleteUser(request: DeleteUserRequest) async throws -> DeleteUserResponse? {
        try await Supabase.shared.client.functions.deleteUser(request: request)
    }
    
    func initiateSongPayout(request: InitiateSongPayoutRequest) async throws -> InitiateSongPayoutResponse? {
        try await Supabase.shared.client.functions.initiateSongPayout(request: request)
    }
    
    func playSong(request: PlaySongRequest) async throws -> PlaySongResponse? {
        try await Supabase.shared.client.functions.playSong(request: request)
    }
    
    func purchaseTokens(request: PurchaseTokensRequest) async throws -> PurchaseTokensResponse? {
        try await Supabase.shared.client.functions.purchaseTokens(request: request)
    }
}
