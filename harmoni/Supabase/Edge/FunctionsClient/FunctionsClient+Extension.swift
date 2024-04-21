//
//  FunctionsClient+Extension.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/21/24.
//

import Foundation
import Supabase

enum EdgeFunctions: String {
    case createWallet = "cryptoWalletCreator"
    case deleteUser = "deleteUser"
    case initiateSongPayout = "songPayout"
    case playSong = "playASong"
    case purchaseTokens = "purchaseTokens"
}

extension FunctionsClient {
    func createWallet(request: CreateWalletRequest) async throws -> CreateWalletResponse? {
        let response: CreateWalletResponse? = try await Supabase.shared.client.functions
            .invoke(
                EdgeFunctions.createWallet.rawValue,
                options: .init(body: request),
                decode: { data, response in
                    guard response.statusCode == 200 else { return nil }
                    return try JSONDecoder().decode(CreateWalletResponse.self, from: data)
                }
            )
        return response
    }
    
    func deleteUser(request: DeleteUserRequest) async throws -> DeleteUserResponse? {
        let response: DeleteUserResponse? = try await Supabase.shared.client.functions
            .invoke(
                EdgeFunctions.deleteUser.rawValue,
                options: .init(body: request),
                decode: { data, response in
                    guard response.statusCode == 200 else { return nil }
                    return try JSONDecoder().decode(DeleteUserResponse.self, from: data)
                }
            )
        return response
    }
    
    func initiateSongPayout(request: InitiateSongPayoutRequest) async throws -> InitiateSongPayoutResponse? {
        let response: InitiateSongPayoutResponse? = try await Supabase.shared.client.functions
            .invoke(
                EdgeFunctions.initiateSongPayout.rawValue,
                options: .init(body: request),
                decode: { data, response in
                    guard response.statusCode == 200 else { return nil }
                    return try JSONDecoder().decode(InitiateSongPayoutResponse.self, from: data)
                }
            )
        return response
    }
    
    func playSong(request: PlaySongRequest) async throws -> PlaySongResponse? {
        let response: PlaySongResponse? = try await Supabase.shared.client.functions
            .invoke(
                EdgeFunctions.playSong.rawValue,
                options: .init(body: request),
                decode: { data, response in
                    guard response.statusCode == 200 else { return nil }
                    return try JSONDecoder().decode(PlaySongResponse.self, from: data)
                }
            )
        return response
    }
    
    func purchaseTokens(request: PurchaseTokensRequest) async throws -> PurchaseTokensResponse? {
        let response: PurchaseTokensResponse? = try await Supabase.shared.client.functions
            .invoke(
                EdgeFunctions.purchaseTokens.rawValue,
                options: .init(body: request),
                decode: { data, response in
                    guard response.statusCode == 200 else { return nil }
                    return try JSONDecoder().decode(PurchaseTokensResponse.self, from: data)
                }
            )
        return response
    }
}
