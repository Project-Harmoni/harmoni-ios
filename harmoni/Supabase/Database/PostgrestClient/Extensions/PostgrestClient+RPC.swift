//
//  PostgrestClient+RPC.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/17/24.
//

import Foundation
import Supabase

enum DBFunctions: String {
    case addManySongTags = "add_many_song_tags"
    case addSongTag = "add_song_tag"
    case editTag = "edit_tag"
    case bulkEditTag = "bulk_edit_tag"
    case deleteTag = "delete_tag"
    case bulkDeleteTag = "bulk_delete_tag"
    case editTrack = "edit_track"
    case deleteTrack = "delete_tracks"
}

extension PostgrestClient {
    func addSongTag(_ param: AddSongTag) async throws {
        _ = try await Supabase.shared.client.database.rpc(
            DBFunctions.addSongTag.rawValue,
            params: param
        )
        .execute()
        .value
    }
    
    func addManySongTags(_ param: AddManySongTags) async throws {
        _ = try await Supabase.shared.client.database.rpc(
            DBFunctions.addManySongTags.rawValue,
            params: param
        )
        .execute()
        .value
    }
    
    func editTag(_ param: EditTag) async throws {
        _ = try await Supabase.shared.client.database.rpc(
            DBFunctions.editTag.rawValue,
            params: param
        )
        .execute()
        .value
    }
    
    func bulkEditTags(_ param: BulkEditTag) async throws {
        _ = try await Supabase.shared.client.database.rpc(
            DBFunctions.bulkEditTag.rawValue,
            params: param
        )
        .execute()
        .value
    }
    
    func deleteTag(_ param: DeleteTag) async throws {
        _ = try await Supabase.shared.client.database.rpc(
            DBFunctions.deleteTag.rawValue,
            params: param
        )
        .execute()
        .value
    }
    
    func bulkDeleteTags(_ param: BulkDeleteTag) async throws {
        _ = try await Supabase.shared.client.database.rpc(
            DBFunctions.bulkDeleteTag.rawValue,
            params: param
        )
        .execute()
        .value
    }
    
    func editTrack(_ param: EditTrack) async throws {
        _ = try await Supabase.shared.client.database.rpc(
            DBFunctions.editTrack.rawValue,
            params: param
        )
        .execute()
        .value
    }
    
    func deleteTrack(_ param: DeleteTrack) async throws {
        _ = try await Supabase.shared.client.database.rpc(
            DBFunctions.deleteTrack.rawValue,
            params: param
        )
        .execute()
        .value
    }
}
