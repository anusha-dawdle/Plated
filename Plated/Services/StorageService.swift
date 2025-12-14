//
//  StorageService.swift
//  Plated
//
//  Created by Claude on 12/14/2025.
//

import FirebaseStorage
import Foundation

@MainActor
class StorageService {
    static let shared = StorageService()

    private let storage = Storage.storage()

    private init() {}

    // MARK: - Profile Images

    func uploadProfileImage(_ imageData: Data, userId: String) async throws -> String {
        let storageRef = storage.reference()
        let profileImageRef = storageRef.child("profileImages/\(userId).jpg")

        // Upload image
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        let _ = try await profileImageRef.putDataAsync(imageData, metadata: metadata)

        // Get download URL
        let downloadURL = try await profileImageRef.downloadURL()
        return downloadURL.absoluteString
    }

    // MARK: - Post Images

    func uploadPostImage(_ imageData: Data, postId: String) async throws -> String {
        let storageRef = storage.reference()
        let postImageRef = storageRef.child("postImages/\(postId).jpg")

        // Upload image
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        let _ = try await postImageRef.putDataAsync(imageData, metadata: metadata)

        // Get download URL
        let downloadURL = try await postImageRef.downloadURL()
        return downloadURL.absoluteString
    }

    // MARK: - Delete Image

    func deleteImage(at path: String) async throws {
        let storageRef = storage.reference()
        let imageRef = storageRef.child(path)

        try await imageRef.delete()
    }
}
