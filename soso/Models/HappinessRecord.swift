//
//  HappinessRecord.swift
//  soso
//
//  Created by 서지우 on 3/12/26.
//

import Foundation

struct HappinessRecord: Identifiable, Codable {
    let id: UUID
    let content: String
    let createdAt: Date
    
    init(id: UUID = UUID(), content: String, createdAt: Date = Date()) {
        self.id = id
        self.content = content
        self.createdAt = createdAt
    }
}
