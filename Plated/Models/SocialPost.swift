//
//  SocialPost.swift
//  Plated
//
//  Created by Claude on 12/14/2025.
//

import Foundation

struct SocialPost: Identifiable, Codable {
    let id: UUID
    var authorId: String
    var authorName: String // Denormalized for performance
    var authorProfileImageUrl: String? // Denormalized for performance
    var imageUrl: String?
    var caption: String
    var mealTag: MealTag
    var reactions: [Reaction]
    var comments: [Comment]
    var isPublic: Bool
    var createdAt: Date

    init(id: UUID = UUID(), authorId: String, authorName: String, authorProfileImageUrl: String? = nil, imageUrl: String? = nil, caption: String, mealTag: MealTag, reactions: [Reaction] = [], comments: [Comment] = [], isPublic: Bool = true, createdAt: Date = Date()) {
        self.id = id
        self.authorId = authorId
        self.authorName = authorName
        self.authorProfileImageUrl = authorProfileImageUrl
        self.imageUrl = imageUrl
        self.caption = caption
        self.mealTag = mealTag
        self.reactions = reactions
        self.comments = comments
        self.isPublic = isPublic
        self.createdAt = createdAt
    }
}

struct Reaction: Identifiable, Codable {
    let id: UUID
    var userId: String
    var emoji: String

    init(id: UUID = UUID(), userId: String, emoji: String) {
        self.id = id
        self.userId = userId
        self.emoji = emoji
    }
}

struct Comment: Identifiable, Codable {
    let id: UUID
    var userId: String
    var userName: String // Denormalized for performance
    var userProfileImageUrl: String? // Denormalized for performance
    var text: String
    var createdAt: Date

    init(id: UUID = UUID(), userId: String, userName: String, userProfileImageUrl: String? = nil, text: String, createdAt: Date = Date()) {
        self.id = id
        self.userId = userId
        self.userName = userName
        self.userProfileImageUrl = userProfileImageUrl
        self.text = text
        self.createdAt = createdAt
    }
}
