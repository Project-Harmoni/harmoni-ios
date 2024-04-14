//
//  PostgrestQueryBulider+Join.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/13/24.
//

import Foundation
import Supabase

extension PostgrestQueryBuilder {
    func innerJoin(table: DatabaseTables, column: String) async throws -> PostgrestFilterBuilder {
        self.select("*, \(table.rawValue)!inner(\(column))")
    }
    
    func innerJoinEq(
        table: DatabaseTables,
        joinedColumn: String,
        equalColumn: String,
        equalValue: URLQueryRepresentable
    ) async throws -> PostgrestFilterBuilder {
        try await self
            .innerJoin(table: table, column: joinedColumn)
            .eq("\(table.rawValue).\(equalColumn)", value: equalValue)
    }
    
    func innerJoinIn(
        table: DatabaseTables,
        joinedColumn: String,
        inColumn: String,
        inValue: [URLQueryRepresentable]
    ) async throws -> PostgrestFilterBuilder {
        try await self
            .innerJoin(table: table, column: joinedColumn)
            .in("\(table.rawValue).\(inColumn)", value: inValue)
    }
}
