//
//  FirebaseDataService.swift
//  Plated
//
//  Created by Claude on 12/14/2025.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

@MainActor
class FirebaseDataService: ObservableObject {
    // MARK: - Published Properties
    @Published var mealPlans: [MealPlan] = []
    @Published var socialPosts: [SocialPost] = []
    @Published var followRequests: [FollowRequest] = []
    @Published var isLoading = false
    @Published var error: String?

    // MARK: - Dependencies
    private let db = Firestore.firestore()
    private let auth = Auth.auth()
    private let storage = Storage.storage()

    // MARK: - Listeners
    private var mealPlansListener: ListenerRegistration?
    private var socialFeedListener: ListenerRegistration?
    private var followRequestsListener: ListenerRegistration?

    // MARK: - Optimistic Update Tracking
    private var lastOptimisticUpdateTime: Date?
    private let optimisticUpdateDebounceInterval: TimeInterval = 0.3

    // MARK: - Current User
    var currentUserId: String? {
        auth.currentUser?.uid
    }

    init() {
        // Listeners will be started when MainTabView appears
    }

    deinit {
        mealPlansListener?.remove()
        socialFeedListener?.remove()
        followRequestsListener?.remove()
    }

    // MARK: - Lifecycle Methods

    func startListening() async {
        guard let userId = currentUserId else { return }

        // Listen to meal plans
        startMealPlansListener(userId: userId)

        // Listen to social feed
        await startSocialFeedListener()

        // Listen to follow requests
        startFollowRequestsListener(userId: userId)
    }

    // MARK: - Meal Planning Methods

    func getMealPlan(for date: Date) -> MealPlan? {
        let calendar = Calendar.current
        return mealPlans.first { calendar.isDate($0.date, inSameDayAs: date) }
    }

    func addMeal(_ meal: MealItem, to date: Date) async throws {
        guard let userId = currentUserId else {
            throw FirebaseDataError.notAuthenticated
        }

        let calendar = Calendar.current

        // Check if meal plan exists for this date
        if let existingPlan = mealPlans.first(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
            // Update existing plan
            var updatedMeals = existingPlan.meals
            updatedMeals.append(meal)

            try await db.collection("mealPlans").document(existingPlan.id.uuidString).updateData([
                "meals": updatedMeals.map { try Firestore.Encoder().encode($0) },
                "updatedAt": FieldValue.serverTimestamp()
            ])
        } else {
            // Create new plan
            let newPlan = MealPlan(
                userId: userId,
                date: date,
                meals: [meal]
            )

            try db.collection("mealPlans").document(newPlan.id.uuidString).setData(from: newPlan)
        }
    }

    func toggleMealCompletion(_ meal: MealItem, on date: Date) async throws {
        guard let planIndex = mealPlans.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }),
              let mealIndex = mealPlans[planIndex].meals.firstIndex(where: { $0.id == meal.id }) else {
            return
        }

        // Optimistic update - update UI immediately
        mealPlans[planIndex].meals[mealIndex].isCompleted.toggle()
        lastOptimisticUpdateTime = Date()

        let plan = mealPlans[planIndex]

        // Then sync with Firestore in background
        do {
            try await db.collection("mealPlans").document(plan.id.uuidString).updateData([
                "meals": plan.meals.map { try Firestore.Encoder().encode($0) },
                "updatedAt": FieldValue.serverTimestamp()
            ])
        } catch {
            // Revert on error
            mealPlans[planIndex].meals[mealIndex].isCompleted.toggle()
            throw error
        }
    }

    func deleteMeal(_ meal: MealItem, from date: Date) async throws {
        guard let plan = getMealPlan(for: date) else { return }

        var updatedMeals = plan.meals
        updatedMeals.removeAll { $0.id == meal.id }

        if updatedMeals.isEmpty {
            // Delete the entire plan if no meals left
            try await db.collection("mealPlans").document(plan.id.uuidString).delete()
        } else {
            // Update with remaining meals
            try await db.collection("mealPlans").document(plan.id.uuidString).updateData([
                "meals": updatedMeals.map { try Firestore.Encoder().encode($0) },
                "updatedAt": FieldValue.serverTimestamp()
            ])
        }
    }

    // MARK: - Social Feed Methods

    func addPost(_ post: SocialPost, image: UIImage?) async throws {
        guard let userId = currentUserId else {
            throw FirebaseDataError.notAuthenticated
        }

        var postToSave = post

        // Upload image if provided
        if let image = image,
           let imageData = image.jpegData(compressionQuality: 0.7) {
            let imageUrl = try await StorageService.shared.uploadPostImage(imageData, postId: post.id.uuidString)
            postToSave.imageUrl = imageUrl
        }

        try db.collection("socialPosts").document(post.id.uuidString).setData(from: postToSave)
    }

    func addReaction(emoji: String, to post: SocialPost) async throws {
        guard let userId = currentUserId else {
            throw FirebaseDataError.notAuthenticated
        }

        let postRef = db.collection("socialPosts").document(post.id.uuidString)

        // Remove existing reaction from this user
        var updatedReactions = post.reactions.filter { $0.userId != userId }

        // Add new reaction
        let newReaction = Reaction(userId: userId, emoji: emoji)
        updatedReactions.append(newReaction)

        try await postRef.updateData([
            "reactions": updatedReactions.map { try Firestore.Encoder().encode($0) }
        ])
    }

    func removeReaction(from post: SocialPost) async throws {
        guard let userId = currentUserId else {
            throw FirebaseDataError.notAuthenticated
        }

        let postRef = db.collection("socialPosts").document(post.id.uuidString)

        // Remove reaction from this user
        let updatedReactions = post.reactions.filter { $0.userId != userId }

        try await postRef.updateData([
            "reactions": updatedReactions.map { try Firestore.Encoder().encode($0) }
        ])
    }

    func addComment(_ text: String, to post: SocialPost, userName: String, userProfileImageUrl: String?) async throws {
        guard let userId = currentUserId else {
            throw FirebaseDataError.notAuthenticated
        }

        let postRef = db.collection("socialPosts").document(post.id.uuidString)

        let newComment = Comment(userId: userId, userName: userName, userProfileImageUrl: userProfileImageUrl, text: text)
        var updatedComments = post.comments
        updatedComments.append(newComment)

        try await postRef.updateData([
            "comments": updatedComments.map { try Firestore.Encoder().encode($0) }
        ])
    }

    // MARK: - Follow System Methods

    func sendFollowRequest(to targetUser: User) async throws {
        guard let currentUser = auth.currentUser,
              let fromUser = try? await getUser(userId: currentUser.uid) else {
            throw FirebaseDataError.notAuthenticated
        }

        // Check if request already exists
        let existingRequests = try await db.collection("followRequests")
            .whereField("fromUserId", isEqualTo: currentUser.uid)
            .whereField("toUserId", isEqualTo: targetUser.id)
            .whereField("status", isEqualTo: FollowRequestStatus.pending.rawValue)
            .getDocuments()

        guard existingRequests.documents.isEmpty else {
            return // Request already exists
        }

        let request = FollowRequest(
            fromUserId: currentUser.uid,
            fromUserName: fromUser.name,
            fromUserUsername: fromUser.username,
            fromUserProfileImageUrl: fromUser.profileImageUrl,
            toUserId: targetUser.id
        )

        try db.collection("followRequests").document(request.id.uuidString).setData(from: request)
    }

    func acceptFollowRequest(_ request: FollowRequest) async throws {
        guard let userId = currentUserId else {
            throw FirebaseDataError.notAuthenticated
        }

        // Update request status
        try await db.collection("followRequests").document(request.id.uuidString).updateData([
            "status": FollowRequestStatus.accepted.rawValue
        ])

        // Update both users' following/followers lists
        let fromUserRef = db.collection("users").document(request.fromUserId)
        let toUserRef = db.collection("users").document(request.toUserId)

        try await fromUserRef.updateData([
            "following": FieldValue.arrayUnion([request.toUserId])
        ])

        try await toUserRef.updateData([
            "followers": FieldValue.arrayUnion([request.fromUserId])
        ])
    }

    func rejectFollowRequest(_ request: FollowRequest) async throws {
        try await db.collection("followRequests").document(request.id.uuidString).updateData([
            "status": FollowRequestStatus.rejected.rawValue
        ])
    }

    func unfollowUser(_ userId: String) async throws {
        guard let currentUserId = currentUserId else {
            throw FirebaseDataError.notAuthenticated
        }

        let currentUserRef = db.collection("users").document(currentUserId)
        let targetUserRef = db.collection("users").document(userId)

        try await currentUserRef.updateData([
            "following": FieldValue.arrayRemove([userId])
        ])

        try await targetUserRef.updateData([
            "followers": FieldValue.arrayRemove([currentUserId])
        ])
    }

    func getFollowStatus(for userId: String) async throws -> FollowStatus {
        guard let currentUserId = currentUserId else {
            throw FirebaseDataError.notAuthenticated
        }

        if currentUserId == userId {
            return .yourself
        }

        // Check if already following
        let currentUser = try await getUser(userId: currentUserId)
        if currentUser.following.contains(userId) {
            return .following
        }

        // Check for pending request
        let pendingRequests = try await db.collection("followRequests")
            .whereField("fromUserId", isEqualTo: currentUserId)
            .whereField("toUserId", isEqualTo: userId)
            .whereField("status", isEqualTo: FollowRequestStatus.pending.rawValue)
            .getDocuments()

        if !pendingRequests.documents.isEmpty {
            return .pending
        }

        return .notFollowing
    }

    func searchUsers(query: String) async throws -> [User] {
        let snapshot = try await db.collection("users")
            .whereField("username", isGreaterThanOrEqualTo: query.lowercased())
            .whereField("username", isLessThanOrEqualTo: query.lowercased() + "\u{f8ff}")
            .limit(to: 20)
            .getDocuments()

        return snapshot.documents.compactMap { try? $0.data(as: User.self) }
    }

    func getUser(userId: String) async throws -> User {
        let document = try await db.collection("users").document(userId).getDocument()
        guard let user = try? document.data(as: User.self) else {
            throw FirebaseDataError.invalidData
        }
        return user
    }

    // MARK: - Real-time Listeners

    private func startMealPlansListener(userId: String) {
        mealPlansListener = db.collection("mealPlans")
            .whereField("userId", isEqualTo: userId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }

                if let error = error {
                    self.error = error.localizedDescription
                    return
                }

                guard let documents = snapshot?.documents else { return }

                // Skip listener updates briefly after optimistic updates to prevent flickering
                if let lastUpdate = self.lastOptimisticUpdateTime,
                   Date().timeIntervalSince(lastUpdate) < self.optimisticUpdateDebounceInterval {
                    return
                }

                self.mealPlans = documents.compactMap { document in
                    try? document.data(as: MealPlan.self)
                }
            }
    }

    private func startSocialFeedListener() async {
        guard let userId = currentUserId else { return }

        // Get current user to access following list
        guard let currentUser = try? await getUser(userId: userId) else { return }

        // Create list of user IDs to show posts from: yourself + people you follow
        var authorIds = currentUser.following
        authorIds.append(userId)

        // If not following anyone yet, only show own posts
        if authorIds.isEmpty {
            authorIds = [userId]
        }

        // Firestore 'in' queries are limited to 10 items, so we need to handle larger following lists
        // For now, limit to first 10 (including self)
        let limitedAuthorIds = Array(authorIds.prefix(10))

        socialFeedListener = db.collection("socialPosts")
            .whereField("authorId", in: limitedAuthorIds)
            .order(by: "createdAt", descending: true)
            .limit(to: 50)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }

                if let error = error {
                    self.error = error.localizedDescription
                    return
                }

                guard let documents = snapshot?.documents else { return }

                self.socialPosts = documents.compactMap { document in
                    try? document.data(as: SocialPost.self)
                }
            }
    }

    private func startFollowRequestsListener(userId: String) {
        // Listen to follow requests where current user is the recipient
        followRequestsListener = db.collection("followRequests")
            .whereField("toUserId", isEqualTo: userId)
            .whereField("status", isEqualTo: FollowRequestStatus.pending.rawValue)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }

                if let error = error {
                    self.error = error.localizedDescription
                    return
                }

                guard let documents = snapshot?.documents else { return }

                self.followRequests = documents.compactMap { document in
                    try? document.data(as: FollowRequest.self)
                }
            }
    }
}

// MARK: - Errors

enum FirebaseDataError: LocalizedError {
    case notAuthenticated
    case invalidData
    case uploadFailed

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "User is not authenticated"
        case .invalidData:
            return "Invalid data format"
        case .uploadFailed:
            return "Failed to upload data"
        }
    }
}

enum FollowStatus {
    case yourself
    case following
    case pending
    case notFollowing
}
