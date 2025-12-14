//
//  SocialFeedView.swift
//  Plated
//
//  Created by Claude on 12/14/2025.
//

import SwiftUI

struct SocialFeedView: View {
    @EnvironmentObject var dataService: MockDataService
    @State private var showingCreatePost = false
    @State private var selectedPost: SocialPost?

    var body: some View {
        NavigationStack {
            Group {
                if dataService.socialPosts.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(dataService.socialPosts) { post in
                                PostCard(
                                    post: post,
                                    currentUser: dataService.currentUser,
                                    onReact: { emoji in
                                        dataService.addReaction(emoji: emoji, to: post, by: dataService.currentUser)
                                    },
                                    onRemoveReaction: {
                                        dataService.removeReaction(from: post, by: dataService.currentUser)
                                    },
                                    onShowComments: {
                                        selectedPost = post
                                    }
                                )
                            }
                        }
                        .padding()
                    }
                    .background(Color(.systemGroupedBackground))
                }
            }
            .navigationTitle("Feed")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingCreatePost = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showingCreatePost) {
                CreatePostView()
            }
            .sheet(item: $selectedPost) { post in
                CommentSheet(
                    post: post,
                    currentUser: dataService.currentUser,
                    onAddComment: { text in
                        dataService.addComment(text, to: post, by: dataService.currentUser)
                    }
                )
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

            Button {
                showingCreatePost = true
            } label: {
                Label("Create Post", systemImage: "plus.circle.fill")
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    SocialFeedView()
        .environmentObject(MockDataService())
}
