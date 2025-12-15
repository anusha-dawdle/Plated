//
//  ProfileView.swift
//  Plated
//
//  Created by Claude on 12/14/2025.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var dataService: FirebaseDataService
    @EnvironmentObject var authService: AuthenticationService
    @State private var showingSearch = false

    private var currentUser: User? {
        authService.currentUser
    }

    private var myPosts: [SocialPost] {
        guard let userId = currentUser?.id.uuidString else { return [] }
        return dataService.socialPosts.filter { $0.authorId == userId }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if let user = currentUser {
                    // Fixed header
                    ProfileHeader(user: user, isOwnProfile: true)
                        .padding()
                        .background(Color(.systemGroupedBackground))

                    Divider()

                    // Scrollable posts
                    if myPosts.isEmpty {
                        emptyState
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(myPosts) { post in
                                    PostCard(post: post, currentUser: user)
                                }
                            }
                            .padding()
                        }
                    }
                } else {
                    Text("Loading profile...")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingSearch = true
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                }
            }
            .sheet(isPresented: $showingSearch) {
                UserSearchView()
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("No posts yet")
                .font(.title3.weight(.medium))

            Text("Share your first meal!")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

struct ProfileHeader: View {
    let user: User
    let isOwnProfile: Bool

    var body: some View {
        VStack(spacing: 16) {
            // Profile image
            if let profileImageUrl = user.profileImageUrl {
                AsyncImage(url: URL(string: profileImageUrl)) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.secondary)
                }
                .frame(width: 80, height: 80)
                .clipShape(Circle())
            } else {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.secondary)
            }

            // Name and username
            VStack(spacing: 4) {
                Text(user.name)
                    .font(.title2.weight(.bold))

                Text("@\(user.username)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // Stats
            HStack(spacing: 32) {
                VStack(spacing: 4) {
                    Text("\(user.followers.count)")
                        .font(.headline)
                    Text("Followers")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                VStack(spacing: 4) {
                    Text("\(user.following.count)")
                        .font(.headline)
                    Text("Following")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ProfileView()
        .environmentObject(FirebaseDataService())
        .environmentObject(AuthenticationService())
}
