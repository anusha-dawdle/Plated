//
//  User.swift
//  Plated
//
//  Created by Claude on 12/14/2025.
//

import Foundation

struct User: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var profileImage: String? // URL or asset name

    init(id: UUID = UUID(), name: String, profileImage: String? = nil) {
        self.id = id
        self.name = name
        self.profileImage = profileImage
    }
}
