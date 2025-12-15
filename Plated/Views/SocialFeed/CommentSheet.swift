//
//  CommentSheet.swift
//  Plated
//
//  Created by Claude on 12/14/2025.
//

import SwiftUI

struct CommentSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataService: MockDataService
    let post: SocialPost
    let currentUser: User
    let onAddComment: (String) -> Void

    @State private var newCommentText = ""
    @FocusState private var isInputFocused: Bool

    // Get the latest version of the post from dataService
    private var latestPost: SocialPost {
        dataService.socialPosts.first { $0.id == post.id } ?? post
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Comments list
                if latestPost.comments.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 16) {
                            ForEach(latestPost.comments) { comment in
                                CommentRow(comment: comment)
                            }
                        }
                        .padding()
                    }
                }

                Divider()

                // Input field
                HStack(spacing: 12) {
                    Image(systemName: "person.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)

                    TextField("Add a comment...", text: $newCommentText, axis: .vertical)
                        .lineLimit(1...4)
                        .focused($isInputFocused)

                    Button("Post") {
                        guard !newCommentText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                        onAddComment(newCommentText)
                        newCommentText = ""
                        isInputFocused = false
                    }
                    .disabled(newCommentText.trimmingCharacters(in: .whitespaces).isEmpty)
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .background(Color(.systemBackground))
            }
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 50))
                .foregroundStyle(.secondary)

            Text("No comments yet")
                .font(.headline)

            Text("Be the first to comment")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct CommentRow: View {
    let comment: Comment

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "person.circle.fill")
                .font(.title2)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(comment.userName)
                        .font(.subheadline.weight(.semibold))

                    Text(comment.createdAt, style: .relative)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text(comment.text)
                    .font(.body)
            }

            Spacer()
        }
    }
}

#Preview {
    CommentSheet(
        post: SocialPost(
            authorId: "1",
            authorName: "Sarah",
            caption: "Delicious pasta!",
            mealTag: .dinner,
            comments: [
                Comment(userId: "2", userName: "You", text: "Looks amazing!"),
                Comment(userId: "3", userName: "Mom", text: "Recipe please!")
            ]
        ),
        currentUser: User(name: "You", email: "you@example.com"),
        onAddComment: { _ in }
    )
    .environmentObject(MockDataService())
}
