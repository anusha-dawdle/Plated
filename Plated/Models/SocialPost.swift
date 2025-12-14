//
//  SocialPost.swift
//  Plated
//
//  Created by Claude on 12/14/2025.
//

import Foundation

struct SocialPost: Identifiable, Codable {
    let id: UUID
    var author: User
    var imageData: Data?
    var caption: String
    var mealTag: MealTag
    var reactions: [Reaction]
    var comments: [Comment]
    var createdAt: Date

    init(id: UUID = UUID(), author: User, imageData: Data? = nil, caption: String, mealTag: MealTag, reactions: [Reaction] = [], comments: [Comment] = [], createdAt: Date = Date()) {
        self.id = id
        self.author = author
        self.imageData = imageData
        self.caption = caption
        self.mealTag = mealTag
        self.reactions = reactions
        self.comments = comments
        self.createdAt = createdAt
    }
}

struct Reaction: Identifiable, Codable {
    let id: UUID
    var user: User
    var emoji: String

    init(id: UUID = UUID(), user: User, emoji: String) {
        self.id = id
        self.user = user
        self.emoji = emoji
    }
}

struct Comment: Identifiable, Codable {
    let id: UUID
    var user: User
    var text: String
    var createdAt: Date

    init(id: UUID = UUID(), user: User, text: String, createdAt: Date = Date()) {
        self.id = id
        self.user = user
        self.text = text
        self.createdAt = createdAt
    }
}
