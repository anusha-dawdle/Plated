//
//  ReactionBar.swift
//  Plated
//
//  Created by Claude on 12/14/2025.
//

import SwiftUI

struct ReactionBar: View {
    let reactions: [Reaction]
    let currentUser: User
    let onReact: (String) -> Void
    let onRemoveReaction: () -> Void

    private let availableEmojis = ["❤️", "👍", "😋", "🔥", "👏"]

    private var groupedReactions: [(String, Int)] {
        let grouped = Dictionary(grouping: reactions) { $0.emoji }
        return grouped.map { ($0.key, $0.value.count) }
            .sorted { $0.1 > $1.1 }
    }

    private var currentUserReaction: String? {
        reactions.first { $0.userId == currentUser.id.uuidString }?.emoji
    }

    var body: some View {
        HStack(spacing: 12) {
            // Show existing reactions
            ForEach(groupedReactions, id: \.0) { emoji, count in
                Button {
                    if emoji == currentUserReaction {
                        onRemoveReaction()
                    } else {
                        onReact(emoji)
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(emoji)
                            .font(.body)
                        Text("\(count)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(emoji == currentUserReaction ? Color.blue.opacity(0.1) : Color(.systemGray6))
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }

            // Add reaction button
            Menu {
                ForEach(availableEmojis, id: \.self) { emoji in
                    Button {
                        onReact(emoji)
                    } label: {
                        Text(emoji)
                    }
                }
            } label: {
                Image(systemName: "face.smiling")
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(.systemGray6))
                    .clipShape(Capsule())
            }
        }
    }
}

#Preview {
    VStack {
        ReactionBar(
            reactions: [
                Reaction(userId: "1", emoji: "❤️"),
                Reaction(userId: "2", emoji: "❤️"),
                Reaction(userId: "3", emoji: "😋")
            ],
            currentUser: User(name: "You", email: "you@example.com"),
            onReact: { _ in },
            onRemoveReaction: {}
        )
    }
    .padding()
}
