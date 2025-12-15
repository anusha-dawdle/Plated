//
//  UserProfileView.swift
//  Plated
//
//  Created by Claude on 12/14/2025.
//

import SwiftUI

struct UserProfileView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataService: FirebaseDataService
    @EnvironmentObject var authService: AuthenticationService

    let user: User
    @State private var followStatus: FollowStatus = .notFollowing
    @State private var isLoading = false

    private var userPosts: [SocialPost] {
        dataService.socialPosts.filter { $0.authorId == user.id.uuidString }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Fixed header
            VStack(spacing: 16) {
                ProfileHeader(user: user, isOwnProfile: false)
                    .padding()

                // Follow button
                followButton
                    .padding(.horizontal)
                    .padding(.bottom)
            }
            .background(Color(.systemGroupedBackground))

            Divider()

            // Scrollable posts
            if userPosts.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(userPosts) { post in
                            if let currentUser = authService.currentUser {
                                PostCard(post: post, currentUser: currentUser)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle(user.username)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadFollowStatus()
        }
    }

    @ViewBuilder
    private var followButton: some View {
        switch followStatus {
        case .yourself:
            EmptyView()
        case .notFollowing:
            Button {
                Task {
                    await sendFollowRequest()
                }
            } label: {
                Text("Follow")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLoading)
        case .pending:
            Button {
                // Can't cancel request for now
            } label: {
                Text("Pending")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.bordered)
            .disabled(true)
        case .following:
            Button {
                Task {
                    await unfollowUser()
                }
            } label: {
                Text("Following")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.bordered)
            .disabled(isLoading)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("No posts yet")
                .font(.title3.weight(.medium))

            Text("\(user.name) hasn't shared any meals")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }

    private func loadFollowStatus() async {
        do {
            followStatus = try await dataService.getFollowStatus(for: user.id.uuidString)
        } catch {
            print("Error loading follow status: \(error)")
        }
    }

    private func sendFollowRequest() async {
        isLoading = true
        do {
            try await dataService.sendFollowRequest(to: user)
            followStatus = .pending
        } catch {
            print("Error sending follow request: \(error)")
        }
        isLoading = false
    }

    private func unfollowUser() async {
        isLoading = true
        do {
            try await dataService.unfollowUser(user.id.uuidString)
            followStatus = .notFollowing
        } catch {
            print("Error unfollowing user: \(error)")
        }
        isLoading = false
    }
}

#Preview {
    NavigationStack {
        UserProfileView(
            user: User(name: "Sarah", username: "sarah_eats", email: "sarah@example.com")
        )
        .environmentObject(FirebaseDataService())
        .environmentObject(AuthenticationService())
    }
}
