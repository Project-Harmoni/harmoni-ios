//
//  RPCProviding.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/17/24.
//

import Foundation

protocol RPCProviding {
    func addSongTag(_ param: AddSongTag) async throws
    func addManySongTags(_ param: AddManySongTags) async throws
    func editTag(_ param: EditTag) async throws
    func bulkEditTags(_ param: BulkEditTag) async throws
    func deleteTag(_ param: DeleteTag) async throws
    func bulkDeleteTags(_ param: BulkDeleteTag) async throws
    func editTrack(_ param: EditTrack) async throws
    func deleteTrack(_ param: DeleteTrack) async throws
}

struct RPCProvider: RPCProviding {
    func addSongTag(_ param: AddSongTag) async throws {
        _ = try await Supabase.shared.client.database.addSongTag(param)
    }
    
    func addManySongTags(_ param: AddManySongTags) async throws {
        _ = try await Supabase.shared.client.database.addManySongTags(param)
    }
    
    func editTag(_ param: EditTag) async throws {
        _ = try await Supabase.shared.client.database.editTag(param)
    }
    
    func bulkEditTags(_ param: BulkEditTag) async throws {
        _ = try await Supabase.shared.client.database.bulkEditTags(param)
    }
    
    func deleteTag(_ param: DeleteTag) async throws {
        _ = try await Supabase.shared.client.database.deleteTag(param)
    }
    
    func bulkDeleteTags(_ param: BulkDeleteTag) async throws {
        _ = try await Supabase.shared.client.database.bulkDeleteTags(param)
    }
    
    func editTrack(_ param: EditTrack) async throws {
        _ = try await Supabase.shared.client.database.editTrack(param)
    }
    
    func deleteTrack(_ param: DeleteTrack) async throws {
        _ = try await Supabase.shared.client.database.deleteTrack(param)
    }
}
