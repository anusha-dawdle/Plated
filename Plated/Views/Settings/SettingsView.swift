//
//  SettingsView.swift
//  Plated
//
//  Created by Claude on 12/14/2025.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authService: AuthenticationService
    @State private var showSignOutAlert = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            List {
                // Profile Section
                Section {
                    HStack(spacing: 16) {
                        // Profile Image
                        if let profileImageUrl = authService.currentUser?.profileImageUrl {
                            AsyncImage(url: URL(string: profileImageUrl)) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .foregroundStyle(.gray)
                            }
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .foregroundStyle(.gray)
                                .frame(width: 60, height: 60)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(authService.currentUser?.name ?? "User")
                                .font(.headline)

                            Text(authService.currentUser?.email ?? "")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }

                // Account Section
                Section("Account") {
                    Button(role: .destructive) {
                        showSignOutAlert = true
                    } label: {
                        Label("Sign Out", systemImage: "arrow.right.square")
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Sign Out", isPresented: $showSignOutAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Sign Out", role: .destructive) {
                    signOut()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func signOut() {
        do {
            try authService.signOut()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthenticationService())
}
