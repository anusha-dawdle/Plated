//
//  UserSearchView.swift
//  Plated
//
//  Created by Claude on 12/14/2025.
//

import SwiftUI

struct UserSearchView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataService: FirebaseDataService
    @State private var searchQuery = ""
    @State private var searchResults: [User] = []
    @State private var isSearching = false

    var body: some View {
        NavigationStack {
            Group {
                if searchResults.isEmpty && !searchQuery.isEmpty && !isSearching {
                    emptyState
                } else if searchResults.isEmpty {
                    placeholderState
                } else {
                    List(searchResults) { user in
                        NavigationLink(destination: UserProfileView(user: user)) {
                            UserRow(user: user)
                        }
                    }
                }
            }
            .searchable(text: $searchQuery, prompt: "Search by username")
            .onChange(of: searchQuery) { _, newValue in
                Task {
                    await performSearch(query: newValue)
                }
            }
            .navigationTitle("Find Users")
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
        VStack(spacing: 16) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("No users found")
                .font(.title3.weight(.medium))

            Text("Try searching for a different username")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var placeholderState: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("Search for users")
                .font(.title3.weight(.medium))

            Text("Enter a username to find people")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func performSearch(query: String) async {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            searchResults = []
            return
        }

        isSearching = true
        do {
            searchResults = try await dataService.searchUsers(query: query)
        } catch {
            print("Error searching users: \(error)")
            searchResults = []
        }
        isSearching = false
    }
}

struct UserRow: View {
    let user: User

    var body: some View {
        HStack(spacing: 12) {
            // Profile image
            if let profileImageUrl = user.profileImageUrl {
                AsyncImage(url: URL(string: profileImageUrl)) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .font(.title)
                        .foregroundStyle(.secondary)
                }
                .frame(width: 44, height: 44)
                .clipShape(Circle())
            } else {
                Image(systemName: "person.circle.fill")
                    .font(.title)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(user.name)
                    .font(.headline)

                Text("@\(user.username)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }
}

#Preview {
    UserSearchView()
        .environmentObject(FirebaseDataService())
}
