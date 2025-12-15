//
//  User.swift
//  Plated
//
//  Created by Claude on 12/14/2025.
//

import Foundation

struct User: Identifiable, Codable, Equatable {
    let id: String  // Firebase Auth UID
    var name: String
    var username: String
    var email: String
    var profileImageUrl: String?
    var followers: [String] // Array of user IDs
    var following: [String] // Array of user IDs
    var createdAt: Date

    init(id: String = UUID().uuidString, name: String, username: String = "", email: String = "", profileImageUrl: String? = nil, followers: [String] = [], following: [String] = [], createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.username = username
        self.email = email
        self.profileImageUrl = profileImageUrl
        self.followers = followers
        self.following = following
        self.createdAt = createdAt
    }

    // Legacy property for backwards compatibility with MockDataService
    var profileImage: String? {
        get { profileImageUrl }
        set { profileImageUrl = newValue }
    }
}
