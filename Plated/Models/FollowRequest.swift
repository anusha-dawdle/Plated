//
//  FollowRequest.swift
//  Plated
//
//  Created by Claude on 12/14/2025.
//

import Foundation

struct FollowRequest: Identifiable, Codable {
    let id: UUID
    var fromUserId: String
    var fromUserName: String // Denormalized for performance
    var fromUserUsername: String // Denormalized for performance
    var fromUserProfileImageUrl: String? // Denormalized for performance
    var toUserId: String
    var status: FollowRequestStatus
    var createdAt: Date

    init(id: UUID = UUID(), fromUserId: String, fromUserName: String, fromUserUsername: String, fromUserProfileImageUrl: String? = nil, toUserId: String, status: FollowRequestStatus = .pending, createdAt: Date = Date()) {
        self.id = id
        self.fromUserId = fromUserId
        self.fromUserName = fromUserName
        self.fromUserUsername = fromUserUsername
        self.fromUserProfileImageUrl = fromUserProfileImageUrl
        self.toUserId = toUserId
        self.status = status
        self.createdAt = createdAt
    }
}

enum FollowRequestStatus: String, Codable {
    case pending
    case accepted
    case rejected
}
