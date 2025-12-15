//
//  AuthenticationService.swift
//  Plated
//
//  Created by Claude on 12/14/2025.
//

import FirebaseAuth
import FirebaseFirestore
import FirebaseCore
import GoogleSignIn
import SwiftUI

@MainActor
class AuthenticationService: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var needsProfileSetup = false
    @Published var authError: String?

    private let auth = Auth.auth()
    private let db = Firestore.firestore()

    init() {
        // Check if user is already signed in
        checkAuthState()
    }

    // MARK: - Authentication State

    func checkAuthState() {
        if let firebaseUser = auth.currentUser {
            // User is signed in, fetch their profile
            Task {
                await fetchUserProfile(userId: firebaseUser.uid)
            }
        } else {
            isAuthenticated = false
            currentUser = nil
        }
    }

    // MARK: - Google Sign-In

    func signInWithGoogle() async throws {
        // Get the client ID from Firebase configuration
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw AuthError.missingClientID
        }

        // Configure Google Sign-In
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        // Get the root view controller
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            throw AuthError.noRootViewController
        }

        // Perform Google Sign-In
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        let user = result.user

        guard let idToken = user.idToken?.tokenString else {
            throw AuthError.missingIDToken
        }

        let accessToken = user.accessToken.tokenString

        // Create Firebase credential
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)

        // Sign in to Firebase
        let authResult = try await auth.signIn(with: credential)

        // Create or update user profile
        await createOrUpdateUserProfile(firebaseUser: authResult.user, googleUser: user)
    }

    // MARK: - User Profile Management

    private func createOrUpdateUserProfile(firebaseUser: FirebaseAuth.User, googleUser: GIDGoogleUser) async {
        let userId = firebaseUser.uid
        let userRef = db.collection("users").document(userId)

        do {
            // Check if user already exists
            let snapshot = try await userRef.getDocument()

            if snapshot.exists {
                // User exists, fetch their profile
                await fetchUserProfile(userId: userId)
                // Returning user, no need for profile setup
                self.needsProfileSetup = false
            } else {
                // New user, create profile
                let newUser = User(
                    id: UUID(uuidString: userId) ?? UUID(),
                    name: googleUser.profile?.name ?? "User",
                    email: googleUser.profile?.email ?? "",
                    profileImageUrl: googleUser.profile?.imageURL(withDimension: 200)?.absoluteString,
                    followers: [],
                    following: [],
                    createdAt: Date()
                )

                // Save to Firestore
                try await userRef.setData([
                    "id": userId,
                    "name": newUser.name,
                    "email": newUser.email,
                    "profileImageUrl": newUser.profileImageUrl ?? "",
                    "followers": [],
                    "following": [],
                    "createdAt": newUser.createdAt
                ])

                // Update local state
                self.currentUser = newUser
                self.isAuthenticated = true
                // New user needs profile setup
                self.needsProfileSetup = true
            }
        } catch {
            authError = "Failed to create user profile: \(error.localizedDescription)"
        }
    }

    private func fetchUserProfile(userId: String) async {
        let userRef = db.collection("users").document(userId)

        do {
            let snapshot = try await userRef.getDocument()

            if let data = snapshot.data() {
                let user = User(
                    id: UUID(uuidString: userId) ?? UUID(),
                    name: data["name"] as? String ?? "User",
                    email: data["email"] as? String ?? "",
                    profileImageUrl: data["profileImageUrl"] as? String,
                    followers: data["followers"] as? [String] ?? [],
                    following: data["following"] as? [String] ?? [],
                    createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
                )

                self.currentUser = user
                self.isAuthenticated = true
            }
        } catch {
            authError = "Failed to fetch user profile: \(error.localizedDescription)"
        }
    }

    func updateProfile(name: String, profileImage: UIImage?) async throws {
        guard let userId = auth.currentUser?.uid else {
            throw AuthError.noCurrentUser
        }

        let userRef = db.collection("users").document(userId)

        do {
            // Upload profile image if provided
            var profileImageUrl: String? = currentUser?.profileImageUrl

            if let image = profileImage,
               let imageData = image.jpegData(compressionQuality: 0.7) {
                profileImageUrl = try await StorageService.shared.uploadProfileImage(imageData, userId: userId)
            }

            // Update Firestore
            try await userRef.updateData([
                "name": name,
                "profileImageUrl": profileImageUrl ?? ""
            ])

            // Update local state
            if var updatedUser = currentUser {
                updatedUser.name = name
                updatedUser.profileImageUrl = profileImageUrl
                self.currentUser = updatedUser
            }

            // Profile setup is complete
            self.needsProfileSetup = false
        } catch {
            throw error
        }
    }

    // MARK: - Sign Out

    func signOut() throws {
        try auth.signOut()
        GIDSignIn.sharedInstance.signOut()

        currentUser = nil
        isAuthenticated = false
        needsProfileSetup = false
    }
}

// MARK: - Auth Errors

enum AuthError: LocalizedError {
    case missingClientID
    case noRootViewController
    case missingIDToken
    case noCurrentUser

    var errorDescription: String? {
        switch self {
        case .missingClientID:
            return "Missing Firebase client ID"
        case .noRootViewController:
            return "Cannot find root view controller"
        case .missingIDToken:
            return "Missing Google ID token"
        case .noCurrentUser:
            return "No authenticated user found"
        }
    }
}
