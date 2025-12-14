//
//  PostCard.swift
//  Plated
//
//  Created by Claude on 12/14/2025.
//

import SwiftUI

struct PostCard: View {
    let post: SocialPost
    let currentUser: User
    let onReact: (String) -> Void
    let onRemoveReaction: () -> Void
    let onShowComments: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header: Profile + Name
            HStack(spacing: 12) {
                Image(systemName: post.author.profileImage ?? "person.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 2) {
                    Text(post.author.name)
                        .font(.subheadline.weight(.semibold))

                    Text(post.createdAt, style: .relative)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Meal tag badge
                HStack(spacing: 4) {
                    Image(systemName: post.mealTag.icon)
                    Text(post.mealTag.rawValue)
                }
                .font(.caption)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.1))
                .foregroundStyle(.blue)
                .clipShape(Capsule())
            }
            .padding(.horizontal)

            // Food image
            if let imageData = post.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 300)
                    .clipped()
            } else {
                // Placeholder if no image
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(height: 300)
                    .overlay {
                        VStack(spacing: 8) {
                            Image(systemName: "photo")
                                .font(.system(size: 50))
                            Text("No photo")
                                .font(.caption)
                        }
                        .foregroundStyle(.secondary)
                    }
            }

            // Caption
            if !post.caption.isEmpty {
                Text(post.caption)
                    .font(.body)
                    .padding(.horizontal)
            }

            // Reactions bar
            ScrollView(.horizontal, showsIndicators: false) {
                ReactionBar(
                    reactions: post.reactions,
                    currentUser: currentUser,
                    onReact: onReact,
                    onRemoveReaction: onRemoveReaction
                )
                .padding(.horizontal)
            }

            // Comments button
            Button {
                onShowComments()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "bubble.left")
                    Text(post.comments.isEmpty ? "Add a comment" : "\(post.comments.count) \(post.comments.count == 1 ? "comment" : "comments")")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
    }
}

#Preview {
    ScrollView {
        PostCard(
            post: SocialPost(
                author: User(name: "Sarah", profileImage: "person.circle.fill"),
                imageData: nil,
                caption: "Homemade pizza night!",
                mealTag: .dinner,
                reactions: [
                    Reaction(user: User(name: "You"), emoji: "❤️"),
                    Reaction(user: User(name: "Mom"), emoji: "😋")
                ],
                comments: [
                    Comment(user: User(name: "You"), text: "Looks delicious!")
                ]
            ),
            currentUser: User(name: "You"),
            onReact: { _ in },
            onRemoveReaction: {},
            onShowComments: {}
        )
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}
